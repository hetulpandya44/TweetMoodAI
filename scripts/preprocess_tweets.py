"""
Tweet Preprocessing for Sentiment Analysis Training
Cleans text by removing URLs, mentions, hashtags, and converting emojis to text
"""
import json
import argparse
import re
from pathlib import Path
from datetime import datetime

try:
    import emoji
    EMOJI_AVAILABLE = True
except ImportError:
    EMOJI_AVAILABLE = False
    print("⚠️  emoji library not found. Emoji conversion will be skipped.")
    print("   Install with: pip install emoji")

def remove_urls(text):
    """Remove URLs from text."""
    # Remove http/https URLs
    url_pattern = r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
    text = re.sub(url_pattern, '', text)
    # Remove www URLs
    url_pattern = r'www\.(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
    text = re.sub(url_pattern, '', text)
    return text.strip()

def remove_mentions(text):
    """Remove @mentions from text."""
    # Remove @username mentions
    mention_pattern = r'@\w+'
    text = re.sub(mention_pattern, '', text)
    return text.strip()

def remove_hashtags(text):
    """Remove #hashtags from text (but keep the word)."""
    # Remove # symbol but keep the word
    text = re.sub(r'#(\w+)', r'\1', text)
    return text.strip()

def remove_hashtags_completely(text):
    """Remove #hashtags completely from text."""
    # Remove #hashtag entirely
    text = re.sub(r'#\w+', '', text)
    return text.strip()

def convert_emojis_to_text(text):
    """Convert emojis to their text descriptions."""
    if EMOJI_AVAILABLE:
        # Convert emojis to text descriptions
        text = emoji.demojize(text, language='en')
        # Clean up the format (replace :emoji_name: with emoji_name)
        text = re.sub(r':([a-z_]+):', r'\1', text)
    return text.strip()

def clean_whitespace(text):
    """Clean up extra whitespace."""
    # Replace multiple spaces with single space
    text = re.sub(r'\s+', ' ', text)
    # Remove leading/trailing whitespace
    text = text.strip()
    return text

def preprocess_text(text, remove_hashtag_symbols=True):
    """
    Preprocess tweet text by cleaning URLs, mentions, hashtags, and emojis.
    
    Args:
        text: Raw tweet text
        remove_hashtag_symbols: If True, remove # symbols but keep words. If False, remove hashtags completely.
    
    Returns:
        Cleaned text
    """
    if not text:
        return ""
    
    # Step 1: Remove URLs
    text = remove_urls(text)
    
    # Step 2: Remove mentions (@username)
    text = remove_mentions(text)
    
    # Step 3: Handle hashtags
    if remove_hashtag_symbols:
        # Remove # but keep the word
        text = remove_hashtags(text)
    else:
        # Remove hashtags completely
        text = remove_hashtags_completely(text)
    
    # Step 4: Convert emojis to text
    text = convert_emojis_to_text(text)
    
    # Step 5: Clean whitespace
    text = clean_whitespace(text)
    
    return text

def preprocess_tweet_data(tweet, remove_hashtag_symbols=True):
    """
    Preprocess a single tweet data object.
    
    Args:
        tweet: Tweet data dictionary
        remove_hashtag_symbols: How to handle hashtags
    
    Returns:
        Preprocessed tweet dictionary
    """
    # Keep original raw text
    original_text = tweet.get('raw_text', tweet.get('content', ''))
    
    # Preprocess text
    cleaned_text = preprocess_text(original_text, remove_hashtag_symbols)
    
    # Create preprocessed tweet
    preprocessed_tweet = tweet.copy()
    preprocessed_tweet['cleaned_text'] = cleaned_text
    preprocessed_tweet['original_text'] = original_text
    preprocessed_tweet['preprocessed'] = True
    preprocessed_tweet['preprocessing_date'] = datetime.now().isoformat()
    
    return preprocessed_tweet

def load_tweets(input_path):
    """Load tweets from JSON file."""
    input_path = Path(input_path)
    
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")
    
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Handle different JSON structures
    if isinstance(data, dict):
        if 'tweets' in data:
            tweets = data['tweets']
            metadata = data.get('metadata', {})
        else:
            # Assume it's a list wrapped in metadata
            tweets = data.get('data', data.get('tweets', []))
            metadata = data.get('metadata', {})
    elif isinstance(data, list):
        tweets = data
        metadata = {}
    else:
        raise ValueError(f"Unexpected JSON structure in {input_path}")
    
    return tweets, metadata

def save_preprocessed_tweets(tweets, metadata, output_path):
    """Save preprocessed tweets to JSON file."""
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Update metadata
    updated_metadata = metadata.copy()
    updated_metadata['preprocessing_date'] = datetime.now().isoformat()
    updated_metadata['total_tweets'] = len(tweets)
    updated_metadata['preprocessed'] = True
    updated_metadata['note'] = "Text cleaned: URLs, mentions, hashtags removed, emojis converted to text"
    
    output_data = {
        "metadata": updated_metadata,
        "tweets": tweets
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Preprocessed tweets saved to: {output_path}")
    print(f"📊 Total tweets: {len(tweets)}")

def main():
    parser = argparse.ArgumentParser(
        description="Preprocess tweets for sentiment analysis training",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Preprocessing steps:
  1. Remove URLs
  2. Remove @mentions
  3. Remove #hashtags (symbols removed, words kept by default)
  4. Convert emojis to text descriptions
  5. Clean whitespace

Examples:
  # Preprocess default file
  python scripts/preprocess_tweets.py
  
  # Preprocess specific file
  python scripts/preprocess_tweets.py --input data/tweets_snscrape.json
  
  # Remove hashtags completely (not just symbols)
  python scripts/preprocess_tweets.py --remove-hashtags-completely
  
  # Custom output
  python scripts/preprocess_tweets.py --input data/tweets.json --output data/tweets_cleaned.json
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        type=str,
        default='data/tweets_snscrape.json',
        help='Input JSON file path (default: data/tweets_snscrape.json)'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default=None,
        help='Output JSON file path (default: adds _cleaned suffix to input)'
    )
    
    parser.add_argument(
        '--remove-hashtags-completely',
        action='store_true',
        help='Remove hashtags completely instead of just removing # symbol'
    )
    
    args = parser.parse_args()
    
    try:
        print("=" * 60)
        print("Tweet Preprocessing for Training")
        print("=" * 60)
        
        # Determine output path
        if args.output:
            output_path = args.output
        else:
            input_path = Path(args.input)
            output_path = input_path.parent / f"{input_path.stem}_cleaned{input_path.suffix}"
        
        print(f"Input: {args.input}")
        print(f"Output: {output_path}")
        print("=" * 60)
        
        # Load tweets
        print("\n📂 Loading tweets...")
        tweets, metadata = load_tweets(args.input)
        print(f"✅ Loaded {len(tweets)} tweets")
        
        # Preprocess tweets
        print("\n🧹 Preprocessing tweets...")
        print("   - Removing URLs")
        print("   - Removing @mentions")
        if args.remove_hashtags_completely:
            print("   - Removing hashtags completely")
        else:
            print("   - Removing # symbols (keeping words)")
        print("   - Converting emojis to text")
        print("   - Cleaning whitespace")
        
        preprocessed_tweets = []
        for i, tweet in enumerate(tweets):
            preprocessed = preprocess_tweet_data(
                tweet, 
                remove_hashtag_symbols=not args.remove_hashtags_completely
            )
            preprocessed_tweets.append(preprocessed)
            
            # Progress indicator
            if (i + 1) % 50 == 0:
                print(f"   ✅ Processed {i + 1}/{len(tweets)} tweets...")
        
        print(f"\n✅ Preprocessing complete!")
        
        # Show sample
        if preprocessed_tweets:
            print("\n📝 Sample preprocessing:")
            sample = preprocessed_tweets[0]
            print(f"   Original: {sample.get('original_text', sample.get('content', ''))[:80]}...")
            print(f"   Cleaned:  {sample.get('cleaned_text', '')[:80]}...")
        
        # Save preprocessed tweets
        save_preprocessed_tweets(preprocessed_tweets, metadata, output_path)
        
        print("\n✅ Ready for sentiment labeling and model training!")
        
    except FileNotFoundError as e:
        print(f"❌ Error: {e}")
        print(f"\n💡 Make sure you've collected tweets first:")
        print(f"   python scripts/fetch_snscrape.py --hashtag \"AI\" --max_tweets 300")
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
