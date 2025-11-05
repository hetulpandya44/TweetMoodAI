"""
Train DistilBERT-based Sentiment Analysis Model
Fine-tunes distilbert-base-uncased on labeled tweet dataset
"""
import json
import argparse
import os
from pathlib import Path
from collections import Counter
import torch
from torch.utils.data import Dataset, DataLoader
from transformers import (
    DistilBertTokenizer,
    DistilBertForSequenceClassification,
    Trainer,
    TrainingArguments,
    EarlyStoppingCallback
)
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, classification_report
import numpy as np
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Set device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
logger.info(f"Using device: {device}")

class SentimentDataset(Dataset):
    """Dataset class for sentiment analysis."""
    
    def __init__(self, texts, labels, tokenizer, max_length=128):
        self.texts = texts
        self.labels = labels
        self.tokenizer = tokenizer
        self.max_length = max_length
    
    def __len__(self):
        return len(self.texts)
    
    def __getitem__(self, idx):
        text = str(self.texts[idx])
        label = self.labels[idx]
        
        encoding = self.tokenizer(
            text,
            truncation=True,
            padding='max_length',
            max_length=self.max_length,
            return_tensors='pt'
        )
        
        return {
            'input_ids': encoding['input_ids'].flatten(),
            'attention_mask': encoding['attention_mask'].flatten(),
            'labels': torch.tensor(label, dtype=torch.long)
        }

def load_labeled_data(data_path):
    """Load labeled tweets from JSON file."""
    with open(data_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if isinstance(data, dict) and 'tweets' in data:
        tweets = data['tweets']
    elif isinstance(data, list):
        tweets = data
    else:
        raise ValueError("Invalid data format")
    
    # Extract labeled tweets
    labeled_tweets = []
    label_map = {"positive": 0, "negative": 1, "neutral": 2}
    
    for tweet in tweets:
        if isinstance(tweet, dict):
            text = tweet.get('cleaned_text') or tweet.get('content') or tweet.get('text', '')
            label = tweet.get('sentiment_label')
            
            if text and label and label.lower() in label_map:
                labeled_tweets.append({
                    'text': text,
                    'label': label_map[label.lower()]
                })
    
    if not labeled_tweets:
        raise ValueError("No labeled tweets found. Make sure tweets have 'sentiment_label' field with 'positive', 'negative', or 'neutral'.")
    
    return labeled_tweets, label_map

def compute_metrics(eval_pred):
    """Compute metrics for evaluation."""
    predictions, labels = eval_pred
    predictions = np.argmax(predictions, axis=1)
    
    precision, recall, f1, _ = precision_recall_fscore_support(labels, predictions, average='weighted')
    accuracy = accuracy_score(labels, predictions)
    
    return {
        'accuracy': accuracy,
        'f1': f1,
        'precision': precision,
        'recall': recall
    }

def train_distilbert(
    data_path,
    output_dir='models',
    model_name='distilbert-base-uncased',
    train_split=0.8,
    batch_size=16,
    num_epochs=3,
    learning_rate=2e-5
):
    """
    Train DistilBERT model for sentiment analysis.
    
    Args:
        data_path: Path to labeled JSON data
        output_dir: Directory to save model
        model_name: HuggingFace model name
        train_split: Train/test split ratio
        batch_size: Training batch size
        num_epochs: Number of training epochs
        learning_rate: Learning rate
    """
    logger.info("=" * 60)
    logger.info("DistilBERT Sentiment Analysis Training")
    logger.info("=" * 60)
    
    # Load data
    logger.info(f"Loading data from {data_path}")
    labeled_tweets, label_map = load_labeled_data(data_path)
    
    logger.info(f"Loaded {len(labeled_tweets)} labeled tweets")
    
    # Check label distribution
    label_counts = {}
    for tweet in labeled_tweets:
        label = tweet['label']
        label_counts[label] = label_counts.get(label, 0) + 1
    
    logger.info(f"Label distribution:")
    reverse_label_map = {v: k for k, v in label_map.items()}
    for label_id, count in sorted(label_counts.items()):
        logger.info(f"  {reverse_label_map[label_id]}: {count}")
    
    # Prepare texts and labels
    texts = [tweet['text'] for tweet in labeled_tweets]
    labels = [tweet['label'] for tweet in labeled_tweets]
    
    # Split data (use stratify only if we have at least 2 samples per class)
    try:
        label_counts = Counter(labels)
        # Check if we have at least 2 samples per class for stratify
        can_stratify = all(count >= 2 for count in label_counts.values()) and len(label_counts) > 1
        
        if can_stratify:
            X_train, X_test, y_train, y_test = train_test_split(
                texts, labels, test_size=1-train_split, random_state=42, stratify=labels
            )
        else:
            logger.warning("Cannot use stratify (insufficient samples per class). Using random split.")
            X_train, X_test, y_train, y_test = train_test_split(
                texts, labels, test_size=1-train_split, random_state=42
            )
    except Exception as e:
        logger.warning(f"Error with stratified split: {e}. Using random split.")
        X_train, X_test, y_train, y_test = train_test_split(
            texts, labels, test_size=1-train_split, random_state=42
        )
    
    logger.info(f"Training set: {len(X_train)} samples")
    logger.info(f"Test set: {len(X_test)} samples")
    
    # Initialize tokenizer and model
    logger.info(f"Loading model: {model_name}")
    tokenizer = DistilBertTokenizer.from_pretrained(model_name)
    model = DistilBertForSequenceClassification.from_pretrained(
        model_name,
        num_labels=3  # positive, negative, neutral
    )
    
    # Create datasets
    train_dataset = SentimentDataset(X_train, y_train, tokenizer)
    test_dataset = SentimentDataset(X_test, y_test, tokenizer)
    
    # Training arguments
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    training_args = TrainingArguments(
        output_dir=str(output_path / "checkpoints"),
        num_train_epochs=num_epochs,
        per_device_train_batch_size=batch_size,
        per_device_eval_batch_size=batch_size,
        warmup_steps=100,
        weight_decay=0.01,
        logging_dir=str(output_path / "logs"),
        logging_steps=10,
        eval_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model="f1",
        learning_rate=learning_rate,
        save_total_limit=2,
    )
    
    # Initialize trainer
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=test_dataset,
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=2)]
    )
    
    # Train model
    logger.info("Starting training...")
    trainer.train()
    
    # Evaluate
    logger.info("Evaluating on test set...")
    eval_results = trainer.evaluate()
    
    logger.info("Test Results:")
    for key, value in eval_results.items():
        if isinstance(value, float):
            logger.info(f"  {key}: {value:.4f}")
    
    # Save final model
    final_model_path = output_path / "sentiment_model"
    logger.info(f"Saving model to {final_model_path}")
    trainer.save_model(str(final_model_path))
    tokenizer.save_pretrained(str(final_model_path))
    
    # Save label map
    with open(final_model_path / "label_map.json", 'w') as f:
        json.dump({v: k for k, v in label_map.items()}, f, indent=2)
    
    logger.info("=" * 60)
    logger.info("✅ Training complete!")
    logger.info(f"Model saved to: {final_model_path}")
    logger.info("=" * 60)
    
    # Detailed classification report
    logger.info("\nDetailed Classification Report:")
    predictions = trainer.predict(test_dataset)
    pred_labels = np.argmax(predictions.predictions, axis=1)
    report = classification_report(
        y_test,
        pred_labels,
        target_names=[reverse_label_map[i] for i in sorted(reverse_label_map.keys())]
    )
    logger.info(report)
    
    return trainer, final_model_path

def main():
    parser = argparse.ArgumentParser(
        description="Train DistilBERT sentiment analysis model",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Train with default settings
  python train.py
  
  # Custom data and output
  python train.py --input data/tweets_labeled.json --output models/
  
  # Adjust training parameters
  python train.py --epochs 5 --batch-size 32 --learning-rate 3e-5
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        default='data/tweets_labeled.json',
        help='Input labeled JSON file (default: data/tweets_labeled.json)'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='models/',
        help='Output directory for model (default: models/)'
    )
    
    parser.add_argument(
        '--model-name',
        type=str,
        default='distilbert-base-uncased',
        help='HuggingFace model name (default: distilbert-base-uncased)'
    )
    
    parser.add_argument(
        '--epochs', '-e',
        type=int,
        default=3,
        help='Number of training epochs (default: 3)'
    )
    
    parser.add_argument(
        '--batch-size', '-b',
        type=int,
        default=16,
        help='Batch size (default: 16)'
    )
    
    parser.add_argument(
        '--learning-rate', '-lr',
        type=float,
        default=2e-5,
        help='Learning rate (default: 2e-5)'
    )
    
    parser.add_argument(
        '--train-split',
        type=float,
        default=0.8,
        help='Train/test split ratio (default: 0.8)'
    )
    
    args = parser.parse_args()
    
    try:
        input_path = Path(args.input)
        
        if not input_path.exists():
            logger.error(f"Input file not found: {input_path}")
            logger.info("Make sure you have:")
            logger.info("  1. Collected and preprocessed tweets")
            logger.info("  2. Labeled tweets (run: python scripts/label_tweets.py)")
            return 1
        
        train_distilbert(
            args.input,
            args.output,
            args.model_name,
            args.train_split,
            args.batch_size,
            args.epochs,
            args.learning_rate
        )
        
        logger.info("\n✅ Model training complete!")
        logger.info("Update app/sentiment_analyzer.py to load your trained model.")
        
        return 0
        
    except Exception as e:
        logger.error(f"Error during training: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit(main())

