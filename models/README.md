# Models Directory

This directory stores trained sentiment analysis models.

## File Structure

```
models/
├── sentiment_model.pth          # PyTorch model (after training)
├── sentiment_model.pkl          # Scikit-learn model (alternative)
├── transformers_model/          # Transformers model directory
└── model_metadata.json          # Model metadata and version info
```

## Model Training

After collecting and labeling your training data:

1. Use the preprocessed and labeled data from `data/tweets_snscrape_cleaned.json`
2. Train your sentiment analysis model
3. Save the model to this directory
4. Update `app/sentiment_analyzer.py` to load your trained model

## Model Formats Supported

- **PyTorch**: `.pth` or `.pt` files
- **Scikit-learn**: `.pkl` files  
- **Transformers**: Model directory with config files
- **TensorFlow**: `.h5` or SavedModel format

## Quick Start

After training, save your model:

```python
# PyTorch example
import torch
torch.save(model.state_dict(), 'models/sentiment_model.pth')

# Scikit-learn example
import joblib
joblib.dump(model, 'models/sentiment_model.pkl')
```

