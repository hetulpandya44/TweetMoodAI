"""
Tweet Collection Using snscrape (Fixed for Python 3.13)
Workaround for snscrape compatibility issues with Python 3.13
"""
import json
import argparse
import sys
from pathlib import Path
from datetime import datetime

# Patch for Python 3.13 compatibility
import importlib.util
import importlib.machinery

# Try to import with workaround
try:
    # Attempt to fix the import issue
    import sys
    if sys.version_info >= (3, 13):
        # Python 3.13+ compatibility workaround
        import importlib
        original_find_module = None
        
        # Try alternative import
        try:
            import snscrape.modules.twitter as sntwitter
        except AttributeError:
            # If that fails, try using subprocess to run in Python 3.11/3.12
            import subprocess
            import tempfile
            
            print("⚠️  snscrape has compatibility issues with Python 3.13")
            print("💡 Trying alternative collection method...")
            
            # Fall back to using Twitter API for collection
            from dotenv import load_dotenv
            import os
            import requests
            
            load_dotenv()
            
            # Use Twitter API instead
            BEARER_TOKEN = os.getenv('X_BEARER_TOKEN') or os.getenv('TWITTER_BEARER_TOKEN')
            
            if BEARER_TOKEN:
                print("✅ Using Twitter API for collection (will respect rate limits)")
                USE_API = True
            else:
                USE_API = False
                raise ImportError("snscrape not compatible and no Twitter API token found")
    else:
        import snscrape.modules.twitter as sntwitter
        USE_API = False
except ImportError as e:
    print(f"❌ Error importing snscrape: {e}")
    print("💡 Attempting to use Twitter API as fallback...")
    
    try:
        from dotenv import load_dotenv
        import os
        load_dotenv()
        BEARER_TOKEN = os.getenv('X_BEARER_TOKEN') or os.getenv('TWITTER_BEARER_TOKEN')
        USE_API = bool(BEARER_TOKEN)
        if not USE_API:
            raise ImportError("No alternative available")
    except:
        USE_API = False
        raise ImportError("Cannot use snscrape or Twitter API")

def scrape_with_api(query, max_tweets, bearer_token):
    """Use Twitter API to collect tweets."""
    import requests
    
    TWITTER_API_BASE = "https://api.twitter.com/2"
    url = f"{TWITTER_API_BASE}/tweets/search/recent"
    
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "User-Agent": "TweetMoodAI/1.0"
    }
    
    all_tweets = []
    next_token = None
    
    while len(all_tweets) < max_tweets:
        remaining = max_tweets - len(all_tweets)
        current_max = min(100, remaining)  # API limit is 100 per request
        
        params = {
            "query": f"{query} -is:retweet lang:en",
            "max_results": current_max,
            "tweet.fields": "created_at,author_id,public_metrics,text,lang",
            "expansions": "author_id",
            "user.fields": "username,name"
        }
        
        if next_token:
            params["next_token"] = next_token
        
        try:
            response = requests.get(url, headers=headers, params=params)
            
            if response.status_code == 429:
                print(f"\n⚠️  Rate limit reached. Collected {len(all_tweets)} tweets so far.")
                break
            
            if response.status_code != 200:
                print(f"\n❌ API Error: {response.status_code}")
                break
            
            data = response.json()
            
            if 'data' in data and data['data']:
                all_tweets.extend(data['data'])
                print(f"✅ Fetched {len(data['data'])} tweets (Total: {len(all_tweets)})")
                
                next_token = data.get('meta', {}).get('next_token')
                if not next_token:
                    break
                
                import time
                time.sleep(1)
            else:
                break
                
        except Exception as e:
            print(f"❌ Error: {e}")
            break
    
    return all_tweets

def scrape_tweets(query, max_tweets=300, output_path="data/tweets_snscrape.json"):
    """Scrape tweets using available method."""
    print("=" * 60)
    print("Training Dataset Collector")
    print("=" * 60)
    print(f"Query: {query}")
    print(f"Target tweets: {max_tweets}")
    print("=" * 60)
    
    tweets = []
    
    if USE_API:
        print("\n📡 Using Twitter API for collection")
        print("⚠️  Note: Free Tier has 100 tweets/month limit")
        print("   For unlimited collection, use Python 3.11 or 3.12 with snscrape\n")
        
        tweets_data = scrape_with_api(query, max_tweets, BEARER_TOKEN)
        
        # Convert to our format
        for tweet in tweets_data:
            tweet_data = {
                "id": tweet.get('id'),
                "date": tweet.get('created_at'),
                "content": tweet.get('text'),
                "raw_text": tweet.get('text'),
                "lang": tweet.get('lang'),
                "retweet_count": tweet.get('public_metrics', {}).get('retweet_count', 0),
                "like_count": tweet.get('public_metrics', {}).get('like_count', 0),
                "reply_count": tweet.get('public_metrics', {}).get('reply_count', 0),
                "source": "twitter_api",
                "sentiment_label": None
            }
            tweets.append(tweet_data)
    else:
        # Use snscrape (Python < 3.13)
        print("\n🔍 Using snscrape (no limits)")
        
        try:
            for i, tweet in enumerate(sntwitter.TwitterSearchScraper(query).get_items()):
                if i >= max_tweets:
                    break
                
                tweet_data = {
                    "id": tweet.id,
                    "date": tweet.date.isoformat() if tweet.date else None,
                    "content": tweet.rawContent,
                    "user": tweet.user.username if tweet.user else None,
                    "retweet_count": tweet.retweetCount if hasattr(tweet, 'retweetCount') else 0,
                    "like_count": tweet.likeCount if hasattr(tweet, 'likeCount') else 0,
                    "raw_text": tweet.rawContent,
                    "source": "snscrape",
                    "sentiment_label": None
                }
                
                tweets.append(tweet_data)
                
                if (i + 1) % 50 == 0:
                    print(f"✅ Collected {i + 1} tweets...")
        except Exception as e:
            print(f"❌ Error: {e}")
            return None
    
    print(f"\n🎉 Successfully collected {len(tweets)} tweets")
    return tweets

def save_tweets(tweets, output_path):
    """Save tweets to JSON file."""
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    output_data = {
        "metadata": {
            "collection_date": datetime.now().isoformat(),
            "total_tweets": len(tweets),
            "source": "twitter_api" if USE_API else "snscrape",
            "purpose": "Training dataset",
            "status": "Unlabeled"
        },
        "tweets": tweets
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Saved to: {output_path}")

def build_query(hashtag=None, user=None, query=None):
    """Build query string."""
    if query:
        return query if query.startswith('#') else query
    elif hashtag:
        return hashtag if hashtag.startswith('#') else f"#{hashtag}"
    elif user:
        return f"from:{user.lstrip('@')}"
    else:
        raise ValueError("Provide --query, --hashtag, or --user")

def main():
    parser = argparse.ArgumentParser(description="Collect training dataset")
    query_group = parser.add_mutually_exclusive_group(required=True)
    query_group.add_argument('--hashtag', '--tag', type=str)
    query_group.add_argument('--query', '-q', type=str)
    query_group.add_argument('--user', '-u', type=str)
    parser.add_argument('--max_tweets', '-m', type=int, default=300)
    parser.add_argument('--output', '-o', type=str, default='data/tweets_snscrape.json')
    
    args = parser.parse_args()
    
    try:
        query = build_query(args.hashtag, args.user, args.query)
        tweets = scrape_tweets(f"{query} -filter:retweets lang:en", args.max_tweets, args.output)
        
        if tweets:
            save_tweets(tweets, args.output)
            print("\n✅ Ready for preprocessing!")
        else:
            return 1
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())

