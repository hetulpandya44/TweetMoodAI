"""
Sentiment Analysis Model Training Script
Train your sentiment analysis model using collected and labeled data
"""
import json
import argparse
from pathlib import Path
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, accuracy_score
import joblib
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_labeled_data(data_path: Path):
    """Load labeled tweets from JSON file."""
    with open(data_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if isinstance(data, dict) and 'tweets' in data:
        tweets = data['tweets']
    elif isinstance(data, list):
        tweets = data
    else:
        raise ValueError("Invalid data format")
    
    # Extract tweets with labels
    labeled_tweets = []
    for tweet in tweets:
        if isinstance(tweet, dict):
            text = tweet.get('cleaned_text') or tweet.get('content') or tweet.get('text', '')
            label = tweet.get('sentiment_label')
            
            if text and label:
                labeled_tweets.append({
                    'text': text,
                    'label': label
                })
    
    if not labeled_tweets:
        raise ValueError("No labeled tweets found. Make sure tweets have 'sentiment_label' field.")
    
    return labeled_tweets

def train_sentiment_model(data_path: Path, output_dir: Path, model_type='sklearn'):
    """
    Train sentiment analysis model.
    
    Args:
        data_path: Path to labeled JSON data
        output_dir: Directory to save model
        model_type: Type of model ('sklearn', 'pytorch', 'transformers')
    """
    logger.info(f"Loading data from {data_path}")
    labeled_tweets = load_labeled_data(data_path)
    
    logger.info(f"Loaded {len(labeled_tweets)} labeled tweets")
    
    # Convert to DataFrame
    df = pd.DataFrame(labeled_tweets)
    
    # Check label distribution
    label_counts = df['label'].value_counts()
    logger.info(f"Label distribution:\n{label_counts}")
    
    # Prepare features and labels
    X = df['text'].values
    y = df['label'].values
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    logger.info(f"Training set: {len(X_train)} samples")
    logger.info(f"Test set: {len(X_test)} samples")
    
    if model_type == 'sklearn':
        # Train scikit-learn model
        logger.info("Training scikit-learn model...")
        
        # Vectorize text
        vectorizer = TfidfVectorizer(max_features=5000, ngram_range=(1, 2))
        X_train_vec = vectorizer.fit_transform(X_train)
        X_test_vec = vectorizer.transform(X_test)
        
        # Train classifier
        classifier = LogisticRegression(max_iter=1000, random_state=42)
        classifier.fit(X_train_vec, y_train)
        
        # Evaluate
        y_pred = classifier.predict(X_test_vec)
        accuracy = accuracy_score(y_test, y_pred)
        
        logger.info(f"Test Accuracy: {accuracy:.4f}")
        logger.info("\nClassification Report:")
        logger.info(classification_report(y_test, y_pred))
        
        # Save model
        output_dir.mkdir(parents=True, exist_ok=True)
        model_path = output_dir / "sentiment_model.pkl"
        vectorizer_path = output_dir / "vectorizer.pkl"
        
        joblib.dump(classifier, model_path)
        joblib.dump(vectorizer, vectorizer_path)
        
        logger.info(f"Model saved to {model_path}")
        logger.info(f"Vectorizer saved to {vectorizer_path}")
        
        return classifier, vectorizer
    
    elif model_type == 'pytorch':
        logger.warning("PyTorch training not implemented yet. Use 'sklearn' or implement PyTorch training.")
        return None, None
    
    elif model_type == 'transformers':
        logger.warning("Transformers training not implemented yet. Use 'sklearn' or implement Transformers training.")
        return None, None
    
    else:
        raise ValueError(f"Unknown model type: {model_type}")

def main():
    parser = argparse.ArgumentParser(
        description="Train sentiment analysis model",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Train sklearn model
  python scripts/train_model.py --input data/tweets_snscrape_cleaned.json
  
  # Custom output directory
  python scripts/train_model.py --input data/labeled_tweets.json --output models/
  
  # PyTorch model (when implemented)
  python scripts/train_model.py --input data/labeled_tweets.json --model-type pytorch
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        default='data/tweets_snscrape_cleaned.json',
        help='Input JSON file with labeled tweets (default: data/tweets_snscrape_cleaned.json)'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='models/',
        help='Output directory for model (default: models/)'
    )
    
    parser.add_argument(
        '--model-type',
        type=str,
        default='sklearn',
        choices=['sklearn', 'pytorch', 'transformers'],
        help='Type of model to train (default: sklearn)'
    )
    
    args = parser.parse_args()
    
    try:
        input_path = Path(args.input)
        output_dir = Path(args.output)
        
        if not input_path.exists():
            logger.error(f"Input file not found: {input_path}")
            logger.info("Make sure you have:")
            logger.info("  1. Collected tweets: python scripts/fetch_snscrape.py")
            logger.info("  2. Preprocessed tweets: python scripts/preprocess_tweets.py")
            logger.info("  3. Labeled tweets with sentiment_label field")
            return 1
        
        logger.info("=" * 60)
        logger.info("Sentiment Analysis Model Training")
        logger.info("=" * 60)
        logger.info(f"Input: {input_path}")
        logger.info(f"Output: {output_dir}")
        logger.info(f"Model Type: {args.model_type}")
        logger.info("=" * 60)
        
        train_sentiment_model(input_path, output_dir, args.model_type)
        
        logger.info("\n✅ Training complete!")
        logger.info("Update app/sentiment_analyzer.py to load your trained model.")
        
        return 0
        
    except Exception as e:
        logger.error(f"Error during training: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit(main())

