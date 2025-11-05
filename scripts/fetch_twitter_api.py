"""
Twitter API Tweet Collection Script
Fetches tweets by hashtag, user, or query using Twitter API v2
"""
import os
import json
import argparse
import time
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv
import requests

# Load environment variables
load_dotenv()

# Twitter API v2 endpoints
TWITTER_API_BASE = "https://api.twitter.com/2"

def get_bearer_token():
    """Get bearer token from environment variables."""
    # Try X_BEARER_TOKEN first, then TWITTER_BEARER_TOKEN
    bearer_token = os.getenv('X_BEARER_TOKEN') or os.getenv('TWITTER_BEARER_TOKEN')
    
    if not bearer_token:
        raise ValueError(
            "Bearer token not found! Please set X_BEARER_TOKEN or TWITTER_BEARER_TOKEN in .env file"
        )
    
    return bearer_token

def create_headers(bearer_token):
    """Create headers for Twitter API request."""
    return {
        "Authorization": f"Bearer {bearer_token}",
        "User-Agent": "TweetMoodAI/1.0"
    }

def search_tweets(query, bearer_token, max_tweets=100, tweet_fields=None):
    """
    Search for tweets using Twitter API v2.
    
    Args:
        query: Search query (hashtag, keyword, or user)
        bearer_token: Twitter Bearer Token
        max_tweets: Maximum number of tweets to fetch
        tweet_fields: Additional fields to include
    
    Returns:
        List of tweet data
    """
    if tweet_fields is None:
        tweet_fields = "created_at,author_id,public_metrics,text,lang"
    
    headers = create_headers(bearer_token)
    url = f"{TWITTER_API_BASE}/tweets/search/recent"
    
    all_tweets = []
    next_token = None
    max_results_per_request = min(100, max_tweets)  # API limit is 100 per request
    
    print(f"🔍 Searching for tweets: {query}")
    print(f"📊 Target: {max_tweets} tweets")
    
    while len(all_tweets) < max_tweets:
        remaining = max_tweets - len(all_tweets)
        current_max = min(max_results_per_request, remaining)
        
        params = {
            "query": query,
            "max_results": current_max,
            "tweet.fields": tweet_fields,
            "expansions": "author_id",
            "user.fields": "username,name"
        }
        
        if next_token:
            params["next_token"] = next_token
        
        try:
            response = requests.get(url, headers=headers, params=params)
            
            if response.status_code == 403:
                error_data = response.json() if response.text else {}
                error_detail = error_data.get('detail', '')
                error_reason = error_data.get('reason', '')
                
                if 'client-not-enrolled' in error_reason or 'not enrolled' in error_detail.lower():
                    print("\n❌ API Access Error: Your Twitter Developer App needs to be attached to a Project")
                    print("📋 Steps to fix:")
                    print("   1. Go to https://developer.twitter.com/en/portal/dashboard")
                    print("   2. Create a Project (if you don't have one)")
                    print("   3. Attach your App to the Project")
                    print("   4. Make sure you have appropriate API access level")
                    print("   5. Regenerate your Bearer Token if needed")
                    if error_data.get('registration_url'):
                        print(f"   📎 More info: {error_data.get('registration_url')}")
                else:
                    print(f"\n❌ API Authentication Error (403): {error_detail}")
                raise ValueError("Twitter API authentication failed")
            
            if response.status_code == 429:
                # Rate limit exceeded
                print("⏳ Rate limit exceeded. Waiting 15 minutes...")
                time.sleep(900)  # Wait 15 minutes
                continue
            
            if response.status_code == 401:
                print("\n❌ Authentication Error (401): Invalid Bearer Token")
                print("   Please check your X_BEARER_TOKEN or TWITTER_BEARER_TOKEN in .env file")
                raise ValueError("Invalid Bearer Token")
            
            response.raise_for_status()
            data = response.json()
            
            if 'data' in data and data['data']:
                all_tweets.extend(data['data'])
                print(f"✅ Fetched {len(data['data'])} tweets (Total: {len(all_tweets)})")
                
                # Check for next token
                next_token = data.get('meta', {}).get('next_token')
                if not next_token:
                    print("📄 No more tweets available")
                    break
                
                # Rate limiting: Twitter API allows 300 requests per 15 minutes
                time.sleep(1)  # Be respectful with API calls
            else:
                print("⚠️  No tweets found")
                break
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Error fetching tweets: {e}")
            if hasattr(e.response, 'text'):
                print(f"Response: {e.response.text}")
            break
    
    print(f"\n🎉 Successfully collected {len(all_tweets)} tweets")
    return all_tweets[:max_tweets]  # Ensure we don't exceed max_tweets

def build_query_from_args(hashtag=None, user=None, query=None):
    """
    Build Twitter API query string from arguments.
    
    Args:
        hashtag: Hashtag to search (e.g., "#AI")
        user: Username to search (e.g., "elonmusk")
        query: Raw query string
    
    Returns:
        Formatted query string for Twitter API
    """
    if query:
        # If query is provided, use it directly
        if query.startswith('#'):
            # Hashtag
            return f"{query} -is:retweet lang:en"
        elif query.startswith('@'):
            # User mention
            username = query[1:]
            return f"from:{username} -is:retweet lang:en"
        else:
            # General query
            return f"{query} -is:retweet lang:en"
    
    if hashtag:
        # Format hashtag properly
        hashtag = hashtag if hashtag.startswith('#') else f"#{hashtag}"
        return f"{hashtag} -is:retweet lang:en"
    
    if user:
        # Remove @ if present
        username = user.lstrip('@')
        return f"from:{username} -is:retweet lang:en"
    
    raise ValueError("Please provide either --query, --hashtag, or --user")

def save_tweets(tweets, output_path):
    """Save tweets to JSON file."""
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    output_data = {
        "metadata": {
            "collection_date": datetime.now().isoformat(),
            "total_tweets": len(tweets),
            "source": "Twitter API v2"
        },
        "tweets": tweets
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Tweets saved to: {output_path}")
    print(f"📊 Total tweets saved: {len(tweets)}")

def main():
    parser = argparse.ArgumentParser(
        description="Fetch tweets from Twitter API v2",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 300
  python scripts/fetch_twitter_api.py --hashtag "AI" --max_tweets 100
  python scripts/fetch_twitter_api.py --user "elonmusk" --max_tweets 50
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
        default='data/tweets.json',
        help='Output file path (default: data/tweets.json)'
    )
    
    args = parser.parse_args()
    
    try:
        # Get bearer token
        bearer_token = get_bearer_token()
        
        # Build query
        query = build_query_from_args(
            hashtag=args.hashtag,
            user=args.user,
            query=args.query
        )
        
        print("=" * 60)
        print("Twitter API Tweet Collector")
        print("=" * 60)
        print(f"Query: {query}")
        print(f"Max tweets: {args.max_tweets}")
        print("=" * 60)
        
        # Warning for Free Tier users
        if args.max_tweets > 10:
            print("\n⚠️  WARNING: Free Tier users have 100 tweets/month limit!")
            print(f"   You're requesting {args.max_tweets} tweets.")
            print("   Make sure you haven't exceeded your monthly quota.")
            print("   See TWITTER_API_LIMITS.md for details.\n")
        
        # Fetch tweets
        tweets = search_tweets(
            query=query,
            bearer_token=bearer_token,
            max_tweets=args.max_tweets
        )
        
        # Save tweets
        if tweets:
            save_tweets(tweets, args.output)
        else:
            print("⚠️  No tweets to save")
            
    except ValueError as e:
        print(f"❌ Error: {e}")
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
