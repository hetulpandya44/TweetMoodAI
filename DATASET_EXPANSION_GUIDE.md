# Dataset Expansion and Model Retraining Guide

**Step 13: Optional Dataset Expansion and Model Retraining**

---

## 📋 Overview

This guide covers expanding the dataset with 1000+ real tweets and retraining the model for improved accuracy.

---

## 🔑 Step 1: Configure Twitter API

### Get Twitter API Credentials

1. Go to https://developer.twitter.com/en/portal/dashboard
2. Apply for a developer account (if needed)
3. Create a new app
4. Get your credentials:
   - API Key
   - API Secret
   - Access Token
   - Access Token Secret
   - Bearer Token

### Update Environment Variables

Update your `.env` file:

```env
TWITTER_API_KEY=your_api_key_here
TWITTER_API_SECRET=your_api_secret_here
TWITTER_ACCESS_TOKEN=your_access_token_here
TWITTER_ACCESS_TOKEN_SECRET=your_access_token_secret_here
TWITTER_BEARER_TOKEN=your_bearer_token_here
```

### Test API Connection

```python
# Test script: test_twitter_api.py
import os
from dotenv import load_dotenv
import tweepy

load_dotenv()

# Test connection
auth = tweepy.OAuthHandler(
    os.getenv("TWITTER_API_KEY"),
    os.getenv("TWITTER_API_SECRET")
)
auth.set_access_token(
    os.getenv("TWITTER_ACCESS_TOKEN"),
    os.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

api = tweepy.API(auth)
print("✅ Twitter API connection successful!")
```

---

## 📊 Step 2: Collect Real Tweets

### Option A: Using Tweepy (Recommended)

Create `scripts/collect_tweets.py`:

```python
import tweepy
import pandas as pd
import json
from dotenv import load_dotenv
import os
from pathlib import Path
import time

load_dotenv()

# Twitter API setup
auth = tweepy.OAuthHandler(
    os.getenv("TWITTER_API_KEY"),
    os.getenv("TWITTER_API_SECRET")
)
auth.set_access_token(
    os.getenv("TWITTER_ACCESS_TOKEN"),
    os.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

api = tweepy.API(auth, wait_on_rate_limit=True)

def collect_tweets(query: str, max_tweets: int = 1000):
    """Collect tweets based on query"""
    tweets = []
    
    for tweet in tweepy.Cursor(
        api.search_tweets,
        q=query,
        lang="en",
        tweet_mode="extended"
    ).items(max_tweets):
        tweets.append({
            "text": tweet.full_text,
            "id": tweet.id_str,
            "created_at": tweet.created_at.isoformat(),
            "user": tweet.user.screen_name,
            "retweets": tweet.retweet_count,
            "likes": tweet.favorite_count
        })
    
    return tweets

# Collect tweets
tweets = []
queries = [
    "happy OR excited OR amazing OR great",
    "sad OR angry OR disappointed OR terrible",
    "neutral OR okay OR fine OR normal"
]

for query in queries:
    print(f"Collecting tweets for: {query}")
    tweets.extend(collect_tweets(query, max_tweets=350))
    time.sleep(60)  # Rate limit protection

# Save to file
output_file = Path("data/raw/tweets_expanded.json")
output_file.parent.mkdir(parents=True, exist_ok=True)

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(tweets, f, indent=2, ensure_ascii=False)

print(f"✅ Collected {len(tweets)} tweets")
print(f"📁 Saved to {output_file}")
```

Run:

```powershell
python scripts/collect_tweets.py
```

### Option B: Using snscrape (Alternative)

```python
import snscrape.modules.twitter as sntwitter
import pandas as pd
import json

def collect_tweets_snscrape(query: str, max_tweets: int = 1000):
    """Collect tweets using snscrape"""
    tweets = []
    
    for i, tweet in enumerate(sntwitter.TwitterSearchScraper(query).get_items()):
        if i >= max_tweets:
            break
        
        tweets.append({
            "text": tweet.content,
            "id": str(tweet.id),
            "created_at": tweet.date.isoformat(),
            "user": tweet.user.username,
            "retweets": tweet.retweetCount,
            "likes": tweet.likeCount
        })
    
    return tweets

# Collect tweets
tweets = collect_tweets_snscrape("happy OR excited OR amazing", max_tweets=1000)

# Save to file
with open("data/raw/tweets_expanded.json", "w", encoding="utf-8") as f:
    json.dump(tweets, f, indent=2, ensure_ascii=False)
```

---

## 🏷️ Step 3: Label the Data

### Manual Labeling

1. **Create labeling script** (`scripts/label_tweets.py`):

```python
import json
import pandas as pd
from pathlib import Path

# Load collected tweets
with open("data/raw/tweets_expanded.json", "r", encoding="utf-8") as f:
    tweets = json.load(f)

# Create labeling interface
labeled_data = []

for tweet in tweets:
    print(f"\nTweet: {tweet['text']}")
    label = input("Label (positive/negative/neutral) or 'skip': ").strip().lower()
    
    if label in ['positive', 'negative', 'neutral', 'pos', 'neg', 'neu']:
        label_map = {
            'positive': 'positive', 'pos': 'positive',
            'negative': 'negative', 'neg': 'negative',
            'neutral': 'neutral', 'neu': 'neutral'
        }
        labeled_data.append({
            "text": tweet['text'],
            "label": label_map.get(label, label)
        })
    elif label == 'skip':
        continue
    else:
        print("Invalid label, skipping...")

# Save labeled data
output_file = Path("data/labeled/tweets_labeled.json")
output_file.parent.mkdir(parents=True, exist_ok=True)

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(labeled_data, f, indent=2, ensure_ascii=False)

print(f"\n✅ Labeled {len(labeled_data)} tweets")
```

### Semi-Automated Labeling

Use existing model to pre-label, then manually review:

```python
from app.sentiment_analyzer import analyze_text

# Pre-label with existing model
labeled_data = []

for tweet in tweets:
    result = analyze_text(tweet['text'])
    labeled_data.append({
        "text": tweet['text'],
        "label": result['sentiment'],
        "confidence": result['confidence']
    })

# Review low-confidence predictions
for item in labeled_data:
    if item['confidence'] < 0.7:
        print(f"\nTweet: {item['text']}")
        print(f"Predicted: {item['label']} ({item['confidence']:.2f})")
        new_label = input("Correct label (or 'keep'): ").strip().lower()
        if new_label in ['positive', 'negative', 'neutral']:
            item['label'] = new_label
```

---

## 🔄 Step 4: Preprocess Data

Use existing preprocessing from `scripts/preprocess_data.py`:

```powershell
# Preprocess labeled data
python scripts/preprocess_data.py --input data/labeled/tweets_labeled.json --output data/processed/tweets_processed.json
```

---

## 🎓 Step 5: Retrain Model

### Train with Expanded Dataset

```powershell
# Train with expanded dataset
python train.py --data_path data/processed/tweets_processed.json --output_dir models/sentiment_model_v2
```

### Training Parameters

You can customize training in `train.py`:

```python
# Example: Train with more epochs
python train.py \
    --data_path data/processed/tweets_processed.json \
    --output_dir models/sentiment_model_v2 \
    --num_epochs 5 \
    --batch_size 16 \
    --learning_rate 2e-5
```

---

## 📊 Step 6: Evaluate New Model

### Compare Models

```python
# Evaluate new model
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from sklearn.metrics import accuracy_score, classification_report
import json

# Load test data
with open("data/processed/tweets_processed.json", "r") as f:
    data = json.load(f)

# Split test data
test_data = data['test']  # Assuming train_test_split was used

# Evaluate both models
# ... (compare old vs new model performance)
```

---

## 🚀 Step 7: Deploy New Model

### Update Model Path

1. **Backup old model**:
```powershell
mv models/sentiment_model models/sentiment_model_backup
```

2. **Use new model**:
```powershell
mv models/sentiment_model_v2 models/sentiment_model
```

3. **Update environment variable** (if needed):
```env
MODEL_PATH=models/sentiment_model
```

4. **Restart services**:
```powershell
# Restart backend
docker-compose restart backend

# Or if running locally
# Stop and restart uvicorn
```

---

## 📈 Best Practices

### Data Collection
- ✅ Collect diverse tweets (different topics, styles)
- ✅ Balance classes (similar counts for positive/negative/neutral)
- ✅ Remove duplicates
- ✅ Filter out retweets (if desired)
- ✅ Consider different time periods

### Labeling
- ✅ Label consistently (same criteria)
- ✅ Review low-confidence predictions
- ✅ Have multiple labelers (if possible)
- ✅ Resolve disagreements

### Training
- ✅ Use validation set for early stopping
- ✅ Save checkpoints during training
- ✅ Monitor training metrics
- ✅ Compare with baseline model

### Evaluation
- ✅ Test on held-out test set
- ✅ Evaluate on different tweet types
- ✅ Check for bias (age, gender, etc.)
- ✅ Monitor performance over time

---

## 🎯 Expected Results

### With 1000+ Tweets:
- **Accuracy**: Should improve from baseline
- **Confidence**: More consistent predictions
- **Generalization**: Better on diverse tweets

### Typical Improvements:
- Baseline (small dataset): ~85-90% accuracy
- With 1000+ tweets: ~90-95% accuracy
- With 5000+ tweets: ~95-98% accuracy

---

## 📝 Checklist

- [ ] Twitter API configured and tested
- [ ] Collected 1000+ real tweets
- [ ] Labeled all tweets (or reviewed auto-labels)
- [ ] Preprocessed data
- [ ] Trained new model
- [ ] Evaluated new model performance
- [ ] Compared with baseline
- [ ] Backed up old model
- [ ] Deployed new model
- [ ] Tested in production
- [ ] Monitored performance

---

## 🔗 Related Files

- `train.py` - Model training script
- `scripts/preprocess_data.py` - Data preprocessing
- `scripts/collect_tweets.py` - Tweet collection (create this)
- `scripts/label_tweets.py` - Labeling interface (create this)
- `app/sentiment_analyzer.py` - Model loading and inference

---

**Last Updated**: 2025-11-03

