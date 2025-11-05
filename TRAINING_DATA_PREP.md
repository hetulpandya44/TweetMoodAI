# Training and Testing Dataset Preparation Guide

This guide covers the complete workflow for preparing your training dataset using snscrape to avoid Twitter API rate limits during model development.

## Overview

**Strategy**: Use snscrape for unlimited data collection → Preprocess → Label → Train

This approach:
- ✅ Avoids Twitter API rate limits (100 tweets/month on Free Tier)
- ✅ Allows collecting 300+ tweets for proper training
- ✅ Free and unlimited data collection
- ✅ Clean, preprocessed data ready for ML models

---

## Step-by-Step Workflow

### Step 1: Collect Training Dataset (snscrape)

Collect 300+ tweets using snscrape - **no API limits!**

```bash
# Collect tweets by hashtag (recommended: 300+ tweets)
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 500

# Collect with query
python scripts/fetch_snscrape.py --query "sentiment analysis" --max_tweets 400

# Collect with date range
python scripts/fetch_snscrape.py --hashtag "tech" --max_tweets 300 --since 2024-01-01

# Custom output location
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 500 --output data/my_training_data.json
```

**Output**: `data/tweets_snscrape.json` (or custom path)

**What it does**:
- Collects tweets using snscrape (no API limits)
- Saves raw tweet data with metadata
- Includes placeholder for sentiment labels
- Preserves original text for preprocessing

---

### Step 2: Preprocess Tweets

Clean the text data by removing URLs, mentions, hashtags, and converting emojis.

```bash
# Preprocess default file (data/tweets_snscrape.json)
python scripts/preprocess_tweets.py

# Preprocess specific file
python scripts/preprocess_tweets.py --input data/tweets_snscrape.json

# Remove hashtags completely (not just # symbol)
python scripts/preprocess_tweets.py --remove-hashtags-completely

# Custom output
python scripts/preprocess_tweets.py --input data/tweets.json --output data/tweets_cleaned.json
```

**Output**: `data/tweets_snscrape_cleaned.json` (or custom path)

**Preprocessing steps**:
1. ✅ **Remove URLs** - http://, https://, www.
2. ✅ **Remove @mentions** - @username mentions
3. ✅ **Handle hashtags** - Remove # symbols (keep words) OR remove completely
4. ✅ **Convert emojis** - 😊 → "smiling_face"
5. ✅ **Clean whitespace** - Remove extra spaces

**Example transformation**:
```
Original: "Check out this cool AI project! 🚀 #MachineLearning @technews https://example.com"
Cleaned:  "Check out this cool AI project! rocket MachineLearning"
```

---

### Step 3: Label with Sentiment Classes

Manually or semi-automatically label tweets with sentiment:

- **positive** - Positive sentiment
- **negative** - Negative sentiment  
- **neutral** - Neutral sentiment

**Option A: Manual Labeling**

Open the cleaned JSON file and add `sentiment_label` to each tweet:

```json
{
  "id": "123456",
  "cleaned_text": "This AI technology is amazing!",
  "sentiment_label": "positive"
}
```

**Option B: Semi-Automatic Labeling**

Use keyword-based labeling or pre-trained models to pre-label, then review:

```python
# Example: Keyword-based pre-labeling
positive_keywords = ["good", "great", "amazing", "love", "excellent"]
negative_keywords = ["bad", "terrible", "hate", "awful", "disappointed"]

# Then manually review and correct
```

---

### Step 4: Prepare for Training

Split dataset into training/testing sets:

```python
# Example structure
train_data: 70-80% of labeled tweets
test_data: 20-30% of labeled tweets
```

**Recommended dataset sizes**:
- Minimum: 300 tweets (100 per class if balanced)
- Good: 500-1000 tweets
- Excellent: 1000+ tweets per class

---

## Complete Example Workflow

### 1. Collect Data

```bash
# Collect 500 tweets about AI
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 500
```

**Result**: `data/tweets_snscrape.json` with 500 tweets

---

### 2. Preprocess

```bash
# Clean the tweets
python scripts/preprocess_tweets.py --input data/tweets_snscrape.json
```

**Result**: `data/tweets_snscrape_cleaned.json` with cleaned text

---

### 3. Label (Manual/Semi-Auto)

Open `data/tweets_snscrape_cleaned.json` and add sentiment labels:

```json
{
  "metadata": {
    "total_tweets": 500,
    "preprocessed": true
  },
  "tweets": [
    {
      "id": "123",
      "cleaned_text": "This AI technology is amazing",
      "sentiment_label": "positive",
      ...
    },
    {
      "id": "124", 
      "cleaned_text": "Hate this new feature",
      "sentiment_label": "negative",
      ...
    }
  ]
}
```

---

### 4. Train Model

Use the labeled, preprocessed data to train your sentiment analysis model.

```python
# Load preprocessed and labeled data
with open('data/tweets_snscrape_cleaned.json', 'r') as f:
    data = json.load(f)

# Extract features and labels
tweets = [t['cleaned_text'] for t in data['tweets']]
labels = [t['sentiment_label'] for t in data['tweets']]

# Train your model...
```

---

## File Structure

```
data/
├── tweets_snscrape.json              # Raw collected tweets
├── tweets_snscrape_cleaned.json      # Preprocessed tweets
├── tweets_snscrape_labeled.json      # Labeled tweets (after manual labeling)
└── train_test_split/                 # Training/testing splits
    ├── train.json
    └── test.json
```

---

## Preprocessing Details

### URL Removal
- Removes: `http://`, `https://`, `www.` URLs
- Pattern: Matches full URL strings

### Mention Removal
- Removes: `@username` mentions
- Pattern: `@\w+`

### Hashtag Handling
- **Option 1 (default)**: Remove `#` symbol, keep word
  - `#AI` → `AI`
- **Option 2**: Remove hashtags completely
  - `#AI` → (removed)

### Emoji Conversion
- Converts emojis to text descriptions
- `😊` → `smiling_face`
- `🚀` → `rocket`
- Requires `emoji` library (auto-installed)

### Whitespace Cleaning
- Removes multiple spaces
- Trims leading/trailing whitespace

---

## Dataset Requirements

### Minimum Requirements
- **300+ tweets** total
- Balanced classes (if possible)
- Preprocessed text
- Sentiment labels

### Recommended
- **500-1000+ tweets**
- **Balanced distribution** across sentiment classes
- **Diverse topics** (not just one hashtag)
- **Recent tweets** (for current language patterns)

### For Production
- **1000+ tweets per class**
- **Validated labels** (multiple reviewers)
- **Domain-specific** data if needed

---

## Quality Checks

Before training, verify:

1. ✅ **Dataset size**: At least 300 tweets
2. ✅ **Label coverage**: All tweets have sentiment_label
3. ✅ **Class balance**: Roughly equal distribution
4. ✅ **Text quality**: Cleaned properly (no URLs, etc.)
5. ✅ **Preprocessing**: All tweets preprocessed

---

## Tips for Better Datasets

### 1. Diverse Collection
Collect from multiple sources:
```bash
# Collect from different hashtags
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 200
python scripts/fetch_snscrape.py --hashtag "tech" --max_tweets 200
python scripts/fetch_snscrape.py --hashtag "innovation" --max_tweets 200
```

### 2. Date Ranges
Collect recent tweets for current language:
```bash
python scripts/fetch_snscrape.py --hashtag "AI" --since 2024-01-01 --max_tweets 500
```

### 3. Balanced Classes
When labeling, aim for balanced distribution:
- 33% positive
- 33% negative
- 34% neutral

### 4. Quality Over Quantity
- 300 well-labeled tweets > 1000 poorly-labeled
- Review labels for consistency
- Remove ambiguous tweets

---

## Troubleshooting

### Error: "Input file not found"
**Solution**: Make sure you've collected tweets first:
```bash
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 300
```

### Error: "emoji library not found"
**Solution**: Already auto-handled. If still issues:
```bash
pip install emoji
```

### Preprocessing removes too much
**Solution**: Adjust preprocessing options:
```bash
# Keep hashtag words (default)
python scripts/preprocess_tweets.py

# Remove hashtags completely
python scripts/preprocess_tweets.py --remove-hashtags-completely
```

### Low quality cleaned text
**Solution**: 
- Check original tweets for issues
- Adjust preprocessing parameters
- Manual review of cleaned samples

---

## Next Steps After Preparation

1. ✅ **Data collected** (300+ tweets)
2. ✅ **Data preprocessed** (cleaned text)
3. ✅ **Data labeled** (sentiment classes)
4. → **Train sentiment analysis model**
5. → **Evaluate model performance**
6. → **Deploy model**

---

## Quick Reference

```bash
# 1. Collect
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 500

# 2. Preprocess  
python scripts/preprocess_tweets.py

# 3. Label manually (edit JSON file)

# 4. Train model (your ML code)
```

**Summary**: Collect with snscrape → Preprocess → Label → Train! 🚀

