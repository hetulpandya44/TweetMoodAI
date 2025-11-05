"""
Tweet Collection Using snscrape (No API Limits)
Use this for training data collection - no monthly quotas!
For presentation/demo, use fetch_twitter_api.py (official API)
"""
import json
import argparse
import sys
from pathlib import Path
from datetime import datetime
import snscrape.modules.twitter as sntwitter

def scrape_tweets(query, max_tweets=100, output_path="data/tweets.json"):
    """
    Scrape tweets using snscrape.
    
    Args:
        query: Search query (hashtag, keyword, or user)
        max_tweets: Maximum number of tweets to collect
        output_path: Path to save JSON file
    """
    print("=" * 60)
    print("Tweet Collector (snscrape - No API Limits)")
    print("=" * 60)
    print(f"Query: {query}")
    print(f"Max tweets: {max_tweets}")
    print("=" * 60)
    print("\n💡 Tip: This uses snscrape (no API limits)")
    print("   Use fetch_twitter_api.py for official API presentation\n")
    
    tweets = []
    
    try:
        print(f"🔍 Scraping tweets...")
        
        # Use snscrape to get tweets
        for i, tweet in enumerate(sntwitter.TwitterSearchScraper(query).get_items()):
            if i >= max_tweets:
                break
            
            # Extract tweet data
            tweet_data = {
                "id": tweet.id,
                "date": tweet.date.isoformat() if tweet.date else None,
                "content": tweet.rawContent,
                "user": tweet.user.username if tweet.user else None,
                "user_display_name": tweet.user.displayname if tweet.user else None,
                "retweet_count": tweet.retweetCount if hasattr(tweet, 'retweetCount') else 0,
                "like_count": tweet.likeCount if hasattr(tweet, 'likeCount') else 0,
                "reply_count": tweet.replyCount if hasattr(tweet, 'replyCount') else 0,
                "quote_count": tweet.quoteCount if hasattr(tweet, 'quoteCount') else 0,
                "lang": tweet.lang if hasattr(tweet, 'lang') else None,
                "url": tweet.url if hasattr(tweet, 'url') else None,
                "is_retweet": tweet.retweetedTweet is not None if hasattr(tweet, 'retweetedTweet') else False,
                "source": "snscrape"
            }
            
            tweets.append(tweet_data)
            
            # Progress indicator
            if (i + 1) % 10 == 0:
                print(f"✅ Collected {i + 1} tweets...")
        
        print(f"\n🎉 Successfully collected {len(tweets)} tweets")
        
    except Exception as e:
        print(f"❌ Error scraping tweets: {e}")
        print("\n💡 Troubleshooting:")
        print("   - Check your internet connection")
        print("   - Verify the query format is correct")
        print("   - Try a different search query")
        return None
    
    return tweets

def save_tweets(tweets, output_path):
    """Save tweets to JSON file."""
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    output_data = {
        "metadata": {
            "collection_date": datetime.now().isoformat(),
            "total_tweets": len(tweets),
            "source": "snscrape",
            "note": "Collected using snscrape for training data. Use fetch_twitter_api.py for official API presentation."
        },
        "tweets": tweets
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Tweets saved to: {output_path}")
    print(f"📊 Total tweets saved: {len(tweets)}")

def build_query(hashtag=None, user=None, query=None, since=None, until=None):
    """
    Build snscrape query string.
    
    Args:
        hashtag: Hashtag to search (e.g., "#AI" or "AI")
        user: Username (e.g., "elonmusk" or "@elonmusk")
        query: Raw query string
        since: Start date (YYYY-MM-DD)
        until: End date (YYYY-MM-DD)
    """
    query_parts = []
    
    if query:
        # If query provided, use it directly
        if query.startswith('#'):
            query_parts.append(query)
        elif query.startswith('@'):
            query_parts.append(f"from:{query[1:]}")
        else:
            query_parts.append(query)
    elif hashtag:
        # Format hashtag
        hashtag = hashtag if hashtag.startswith('#') else f"#{hashtag}"
        query_parts.append(hashtag)
    elif user:
        # Format user
        username = user.lstrip('@')
        query_parts.append(f"from:{username}")
    else:
        raise ValueError("Please provide --query, --hashtag, or --user")
    
    # Add date filters if provided
    if since:
        query_parts.append(f"since:{since}")
    if until:
        query_parts.append(f"until:{until}")
    
    # Filter out retweets and set language
    query_parts.append("-filter:retweets")
    query_parts.append("lang:en")
    
    return " ".join(query_parts)

def main():
    parser = argparse.ArgumentParser(
        description="Fetch tweets using snscrape (no API limits - perfect for training!)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Search by hashtag
  python scripts/fetch_tweets_snscrape.py --hashtag "AI" --max_tweets 1000
  
  # Search by user
  python scripts/fetch_tweets_snscrape.py --user "elonmusk" --max_tweets 500
  
  # Search by query with date range
  python scripts/fetch_tweets_snscrape.py --query "artificial intelligence" --max_tweets 2000 --since 2024-01-01
  
  # Custom output
  python scripts/fetch_tweets_snscrape.py --hashtag "AI" --max_tweets 1000 --output data/training_tweets.json

Note: Use this for training (no limits). Use fetch_twitter_api.py for official API presentation.
        """
    )
    
    # Query options (mutually exclusive)
    query_group = parser.add_mutually_exclusive_group(required=True)
    query_group.add_argument(
        '--query', '-q',
        type=str,
        help='Search query (can be hashtag, keyword, or @username)'
    )
    query_group.add_argument(
        '--hashtag', '--tag',
        type=str,
        help='Hashtag to search (e.g., "AI" or "#AI")'
    )
    query_group.add_argument(
        '--user', '-u',
        type=str,
        help='Username to search (e.g., "elonmusk" or "@elonmusk")'
    )
    
    parser.add_argument(
        '--max_tweets', '-m',
        type=int,
        default=100,
        help='Maximum number of tweets to fetch (default: 100)'
    )
    
    parser.add_argument(
        '--output', '-o',
        type=str,
        default='data/tweets_snscrape.json',
        help='Output file path (default: data/tweets_snscrape.json)'
    )
    
    parser.add_argument(
        '--since',
        type=str,
        help='Start date (YYYY-MM-DD format)'
    )
    
    parser.add_argument(
        '--until',
        type=str,
        help='End date (YYYY-MM-DD format)'
    )
    
    args = parser.parse_args()
    
    try:
        # Build query
        query = build_query(
            hashtag=args.hashtag,
            user=args.user,
            query=args.query,
            since=args.since,
            until=args.until
        )
        
        # Scrape tweets
        tweets = scrape_tweets(
            query=query,
            max_tweets=args.max_tweets,
            output_path=args.output
        )
        
        # Save tweets
        if tweets:
            save_tweets(tweets, args.output)
            print("\n✅ Done! Use this data for training your sentiment analysis model.")
            print("💡 For presentation, use: fetch_twitter_api.py (official API)")
        else:
            print("⚠️  No tweets collected")
            return 1
            
    except ValueError as e:
        print(f"❌ Error: {e}")
        return 1
    except KeyboardInterrupt:
        print("\n⚠️  Interrupted by user")
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
