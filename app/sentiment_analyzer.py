"""
Sentiment Analysis Model Integration
Loads trained model and performs sentiment analysis on text
"""
import os
import json
from pathlib import Path
from typing import Dict, Optional, List, Any
import logging

# Try to import torch and transformers (may not be available in all environments)
try:
    import torch  # type: ignore
    from transformers import DistilBertTokenizer, DistilBertForSequenceClassification  # type: ignore
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False
    torch = None  # type: ignore
    DistilBertTokenizer = None  # type: ignore
    DistilBertForSequenceClassification = None  # type: ignore

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Model paths
MODEL_DIR = Path(__file__).parent.parent / "models"
MODEL_PATH = MODEL_DIR / "sentiment_model"  # Trained DistilBERT model
LABEL_MAP_PATH = MODEL_PATH / "label_map.json"

def load_model():
    """
    Load the trained DistilBERT sentiment analysis model.
    """
    if not TORCH_AVAILABLE:
        logger.warning("PyTorch/Transformers not available. Cannot load model.")
        return None
    
    try:
        
        if MODEL_PATH.exists():
            logger.info(f"Loading trained model from {MODEL_PATH}")
            
            # Load tokenizer and model
            if DistilBertTokenizer is None or DistilBertForSequenceClassification is None:
                logger.error("Transformers library not available")
                return None
                
            tokenizer = DistilBertTokenizer.from_pretrained(str(MODEL_PATH))
            model = DistilBertForSequenceClassification.from_pretrained(str(MODEL_PATH))
            model.eval()
            
            # Load label map
            label_map = {}
            if LABEL_MAP_PATH.exists():
                with open(LABEL_MAP_PATH, 'r') as f:
                    label_map = json.load(f)
            
            logger.info("✅ Model loaded successfully")
            return {
                'model': model,
                'tokenizer': tokenizer,
                'label_map': label_map
            }
        else:
            logger.warning(f"Trained model not found at {MODEL_PATH}")
            logger.info("Using placeholder sentiment analysis")
            return None
    except Exception as e:
        logger.error(f"Error loading model: {e}")
        logger.info("Falling back to placeholder sentiment analysis")
        return None

# Initialize model (lazy loading)
_model = None

def get_model():
    """Get or load the sentiment analysis model."""
    global _model
    if _model is None:
        _model = load_model()
    return _model

# Reverse label map for lookup
def get_label_map_reverse():
    """Get reverse label map (name -> id)."""
    model_data = get_model()
    if model_data and 'label_map' in model_data:
        return {v: k for k, v in model_data['label_map'].items()}
    return {}

def analyze_text(text: str) -> Dict[str, Any]:
    """
    Analyze sentiment of a given text using trained DistilBERT model.
    Optimized for low latency inference.
    
    Args:
        text: Text to analyze (will be trimmed to 1000 chars if longer)
    
    Returns:
        Dictionary with sentiment, confidence, and label
    
    Raises:
        ValueError: If text is invalid or empty
    """
    # Validate and preprocess input
    if not text or not isinstance(text, str):
        raise ValueError("Text must be a non-empty string")
    
    text = text.strip()
    if not text:
        raise ValueError("Text cannot be empty or whitespace only")
    
    # Truncate if too long (for performance)
    if len(text) > 1000:
        text = text[:1000]
        logger.debug("Text truncated to 1000 characters")
    
    model_data = get_model()
    
    if model_data is None:
        # Fallback to placeholder if model not loaded
        logger.warning("Model not loaded, using placeholder")
        return placeholder_sentiment_analysis(text)
    
    try:
        # Use trained model
        model = model_data['model']
        tokenizer = model_data['tokenizer']
        label_map = model_data['label_map']
        
        # Tokenize input (optimized for inference)
        inputs = tokenizer(
            text,
            truncation=True,
            padding='max_length',
            max_length=128,
            return_tensors='pt'
        )
        
        # Get predictions (inference mode - no gradients)
        if torch is None:
            logger.error("PyTorch not available")
            return placeholder_sentiment_analysis(text)
            
        with torch.no_grad():
            outputs = model(**inputs)
            predictions = torch.nn.functional.softmax(outputs.logits, dim=-1)
        
        # Get predicted label and confidence
        predicted_id = torch.argmax(predictions, dim=-1).item()
        confidence = predictions[0][predicted_id].item()
        
        # Map label ID to label name
        # Handle both string and int keys in label_map
        label_name = None
        if label_map:
            label_name = label_map.get(str(predicted_id)) or label_map.get(predicted_id)
        
        # Fallback to default mapping if label_map not found or missing
        if not label_name and predicted_id in [0, 1, 2]:
            default_labels = ['positive', 'negative', 'neutral']
            label_name = default_labels[predicted_id]
        elif not label_name:
            label_name = 'neutral'  # Safe fallback
        
        # Format response
        sentiment_map = {
            'positive': 'positive',
            'negative': 'negative',
            'neutral': 'neutral'
        }
        
        sentiment = sentiment_map.get(label_name.lower(), 'neutral')
        
        # Map to short label
        label_short_map = {
            'positive': 'POS',
            'negative': 'NEG',
            'neutral': 'NEU'
        }
        label_short = label_short_map.get(sentiment, 'NEU')
        
        return {
            "sentiment": sentiment,
            "confidence": float(confidence),
            "label": label_short
        }
        
    except Exception as e:
        logger.error(f"Error in model inference: {e}", exc_info=True)
        # Fallback to placeholder
        return placeholder_sentiment_analysis(text)

def analyze_batch_optimized(texts: List[str]) -> List[Dict[str, Any]]:
    """
    Optimized batch analysis function for processing multiple texts.
    Can be used for batch inference optimization in the future.
    
    Args:
        texts: List of texts to analyze
    
    Returns:
        List of sentiment analysis results
    
    Note: Future optimization can implement true batch inference
    by tokenizing all texts together and processing in a single forward pass.
    """
    # For now, process sequentially
    # Future: Can implement true batch inference with torch.no_grad() for all at once
    results = []
    for text in texts:
        try:
            results.append(analyze_text(text))
        except ValueError as e:
            logger.warning(f"Skipping invalid text: {e}")
            results.append({
                "sentiment": "neutral",
                "confidence": 0.0,
                "label": "NEU"
            })
    return results

def placeholder_sentiment_analysis(text: str) -> Dict[str, Any]:
    """
    Placeholder sentiment analysis using simple heuristics.
    Replace this with actual model inference.
    """
    text_lower = text.lower()
    
    # Simple keyword-based placeholder
    positive_words = ["good", "great", "excellent", "amazing", "love", "happy", "best"]
    negative_words = ["bad", "terrible", "awful", "hate", "worst", "disappointed", "sad"]
    
    positive_count = sum(1 for word in positive_words if word in text_lower)
    negative_count = sum(1 for word in negative_words if word in text_lower)
    
    if positive_count > negative_count:
        sentiment = "positive"
        confidence = min(0.7 + (positive_count * 0.1), 0.95)
        label = "POS"
    elif negative_count > positive_count:
        sentiment = "negative"
        confidence = min(0.7 + (negative_count * 0.1), 0.95)
        label = "NEG"
    else:
        sentiment = "neutral"
        confidence = 0.5
        label = "NEU"
    
    return {
        "sentiment": sentiment,
        "confidence": confidence,
        "label": label
    }

def format_result(model_output: Any) -> Optional[Dict[str, Any]]:
    """
    Format model output into standard response format.
    Implement based on your model's output format.
    
    Args:
        model_output: Raw model output (format depends on model)
    
    Returns:
        Formatted result dictionary or None if unable to format
    """
    # TODO: Implement based on model output
    # Example:
    # if isinstance(model_output, dict):
    #     return {
    #         "sentiment": model_output['label'],
    #         "confidence": model_output['score'],
    #         "label": model_output['label_short']
    #     }
    return None  # Placeholder until implemented

# Initialize on import (lazy loading - won't fail if model doesn't exist)
# Model will be loaded on first use via get_model()

