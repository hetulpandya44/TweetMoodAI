"""
Semi-Automatic Tweet Labeling Script
Uses heuristics to pre-label tweets, then saves for manual review
"""
import json
import argparse
from pathlib import Path
from datetime import datetime

def classify_sentiment_heuristic(text):
    """
    Use keyword-based heuristics to suggest sentiment label.
    This is a helper - should be reviewed manually.
    """
    text_lower = text.lower()
    
    # Positive keywords
    positive_keywords = [
        "good", "great", "excellent", "amazing", "wonderful", "fantastic",
        "love", "best", "awesome", "brilliant", "perfect", "outstanding",
        "happy", "excited", "pleased", "satisfied", "impressed", "thrilled",
        "success", "improved", "better", "greatest", "favorite", "enjoy"
    ]
    
    # Negative keywords
    negative_keywords = [
        "bad", "terrible", "awful", "worst", "hate", "disappointed",
        "sad", "angry", "frustrated", "upset", "disaster", "failed",
        "poor", "waste", "regret", "dislike", "horrible", "pathetic",
        "broken", "useless", "problem", "error", "wrong", "failed"
    ]
    
    # Count matches
    positive_score = sum(1 for word in positive_keywords if word in text_lower)
    negative_score = sum(1 for word in negative_keywords if word in text_lower)
    
    # Determine sentiment
    if positive_score > negative_score and positive_score > 0:
        return "positive"
    elif negative_score > positive_score and negative_score > 0:
        return "negative"
    else:
        return "neutral"

def label_tweets(input_path, output_path, use_heuristics=True):
    """
    Label tweets with sentiment.
    
    Args:
        input_path: Path to cleaned JSON file
        output_path: Path to save labeled JSON file
        use_heuristics: If True, pre-label using heuristics
    """
    print("=" * 60)
    print("Tweet Labeling")
    print("=" * 60)
    print(f"Input: {input_path}")
    print(f"Output: {output_path}")
    print("=" * 60)
    
    # Load tweets
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    tweets = data.get('tweets', [])
    metadata = data.get('metadata', {})
    
    print(f"\n📂 Loaded {len(tweets)} tweets")
    
    # Check which tweets already have labels
    already_labeled = sum(1 for t in tweets if t.get('sentiment_label'))
    unlabeled = len(tweets) - already_labeled
    
    print(f"   Already labeled: {already_labeled}")
    print(f"   Unlabeled: {unlabeled}")
    
    if use_heuristics and unlabeled > 0:
        print(f"\n🤖 Applying heuristic labeling to {unlabeled} tweets...")
        
        labeled_count = {"positive": 0, "negative": 0, "neutral": 0}
        
        for tweet in tweets:
            if not tweet.get('sentiment_label'):
                text = tweet.get('cleaned_text') or tweet.get('content') or tweet.get('text', '')
                if text:
                    suggested_label = classify_sentiment_heuristic(text)
                    tweet['sentiment_label'] = suggested_label
                    labeled_count[suggested_label] += 1
        
        print(f"   ✅ Pre-labeled using heuristics:")
        print(f"      Positive: {labeled_count['positive']}")
        print(f"      Negative: {labeled_count['negative']}")
        print(f"      Neutral: {labeled_count['neutral']}")
        print(f"\n⚠️  Please review labels manually for accuracy!")
    
    # Count final labels
    label_counts = {"positive": 0, "negative": 0, "neutral": 0, "null": 0}
    for tweet in tweets:
        label = tweet.get('sentiment_label')
        if label in label_counts:
            label_counts[label] += 1
        else:
            label_counts["null"] += 1
    
    print(f"\n📊 Final label distribution:")
    print(f"   Positive: {label_counts['positive']}")
    print(f"   Negative: {label_counts['negative']}")
    print(f"   Neutral: {label_counts['neutral']}")
    if label_counts['null'] > 0:
        print(f"   ⚠️  Unlabeled: {label_counts['null']}")
    
    # Update metadata
    updated_metadata = metadata.copy()
    updated_metadata['labeling_date'] = datetime.now().isoformat()
    updated_metadata['labeled'] = label_counts['null'] == 0
    updated_metadata['label_distribution'] = {
        "positive": label_counts['positive'],
        "negative": label_counts['negative'],
        "neutral": label_counts['neutral']
    }
    
    # Save labeled tweets
    output_data = {
        "metadata": updated_metadata,
        "tweets": tweets
    }
    
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"\n💾 Labeled tweets saved to: {output_path}")
    
    if label_counts['null'] > 0:
        print(f"\n⚠️  Warning: {label_counts['null']} tweets still unlabeled!")
        print(f"   Please manually label remaining tweets.")
    
    return output_path

def main():
    parser = argparse.ArgumentParser(
        description="Label tweets with sentiment (positive/negative/neutral)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Auto-label using heuristics
  python scripts/label_tweets.py
  
  # Custom input/output
  python scripts/label_tweets.py --input data/cleaned.json --output data/labeled.json
  
  # Manual labeling only (no heuristics)
  python scripts/label_tweets.py --no-heuristics
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        default='data/tweets_snscrape_cleaned.json',
        help='Input cleaned JSON file (default: data/tweets_snscrape_cleaned.json)'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='data/tweets_labeled.json',
        help='Output labeled JSON file (default: data/tweets_labeled.json)'
    )
    
    parser.add_argument(
        '--no-heuristics',
        action='store_true',
        help='Skip heuristic pre-labeling (manual labeling only)'
    )
    
    args = parser.parse_args()
    
    try:
        input_path = Path(args.input)
        
        if not input_path.exists():
            print(f"❌ Input file not found: {input_path}")
            print("   Run preprocessing first: python scripts/preprocess_tweets.py")
            return 1
        
        label_tweets(
            args.input,
            args.output,
            use_heuristics=not args.no_heuristics
        )
        
        print("\n✅ Labeling complete!")
        print("   Next step: Train model with labeled data")
        
        return 0
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit(main())

