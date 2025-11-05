"""
Create a sample training dataset for testing
Useful when snscrape/API have issues or for initial testing
"""
import json
from pathlib import Path
from datetime import datetime

def create_sample_dataset(output_path="data/tweets_snscrape.json", num_tweets=300):
    """Create a sample dataset with example tweets."""
    
    sample_tweets = [
        # Positive tweets
        {"id": "1", "content": "This AI technology is absolutely amazing! I love how it works.", "raw_text": "This AI technology is absolutely amazing! I love how it works."},
        {"id": "2", "content": "Great progress in machine learning today. Excellent work everyone!", "raw_text": "Great progress in machine learning today. Excellent work everyone!"},
        {"id": "3", "content": "Best conference I've attended. So many innovative ideas! 🚀", "raw_text": "Best conference I've attended. So many innovative ideas! 🚀"},
        {"id": "4", "content": "AI is revolutionizing healthcare. This is fantastic news!", "raw_text": "AI is revolutionizing healthcare. This is fantastic news!"},
        {"id": "5", "content": "Wonderful to see positive developments in technology.", "raw_text": "Wonderful to see positive developments in technology."},
        {"id": "6", "content": "Love this new feature! Makes everything so much better.", "raw_text": "Love this new feature! Makes everything so much better."},
        {"id": "7", "content": "Outstanding performance from the team today!", "raw_text": "Outstanding performance from the team today!"},
        {"id": "8", "content": "This product exceeded my expectations. Highly recommended!", "raw_text": "This product exceeded my expectations. Highly recommended!"},
        {"id": "9", "content": "So excited about these new developments. Future looks bright!", "raw_text": "So excited about these new developments. Future looks bright!"},
        {"id": "10", "content": "Amazing results! Can't wait to see what's next.", "raw_text": "Amazing results! Can't wait to see what's next."},
        
        # Negative tweets
        {"id": "11", "content": "This is terrible. Really disappointed with the quality.", "raw_text": "This is terrible. Really disappointed with the quality."},
        {"id": "12", "content": "Worst experience ever. Will never use this again.", "raw_text": "Worst experience ever. Will never use this again."},
        {"id": "13", "content": "Hate how slow this system is. Very frustrating! 😞", "raw_text": "Hate how slow this system is. Very frustrating! 😞"},
        {"id": "14", "content": "Bad service and poor customer support. Not recommended.", "raw_text": "Bad service and poor customer support. Not recommended."},
        {"id": "15", "content": "Awful product quality. Complete waste of money.", "raw_text": "Awful product quality. Complete waste of money."},
        {"id": "16", "content": "Really upset about this situation. Should be better.", "raw_text": "Really upset about this situation. Should be better."},
        {"id": "17", "content": "Terrible update. Everything is broken now.", "raw_text": "Terrible update. Everything is broken now."},
        {"id": "18", "content": "Disappointed with the results. Expected much more.", "raw_text": "Disappointed with the results. Expected much more."},
        {"id": "19", "content": "This is a disaster. Nothing works properly.", "raw_text": "This is a disaster. Nothing works properly."},
        {"id": "20", "content": "Worst decision ever. Regret using this.", "raw_text": "Worst decision ever. Regret using this."},
        
        # Neutral tweets
        {"id": "21", "content": "Just read an article about AI developments today.", "raw_text": "Just read an article about AI developments today."},
        {"id": "22", "content": "The meeting is scheduled for tomorrow at 2pm.", "raw_text": "The meeting is scheduled for tomorrow at 2pm."},
        {"id": "23", "content": "New update released with bug fixes.", "raw_text": "New update released with bug fixes."},
        {"id": "24", "content": "Working on a new project this week.", "raw_text": "Working on a new project this week."},
        {"id": "25", "content": "The data shows interesting patterns.", "raw_text": "The data shows interesting patterns."},
        {"id": "26", "content": "Conference happening next month in San Francisco.", "raw_text": "Conference happening next month in San Francisco."},
        {"id": "27", "content": "Reviewed the latest research papers.", "raw_text": "Reviewed the latest research papers."},
        {"id": "28", "content": "System is running normally today.", "raw_text": "System is running normally today."},
        {"id": "29", "content": "Published a blog post about technology trends.", "raw_text": "Published a blog post about technology trends."},
        {"id": "30", "content": "Working with team on implementation details.", "raw_text": "Working with team on implementation details."},
    ]
    
    # Expand the dataset to reach num_tweets
    expanded_tweets = []
    for i in range(num_tweets):
        base_tweet = sample_tweets[i % len(sample_tweets)].copy()
        base_tweet['id'] = str(i + 1)
        base_tweet['date'] = datetime.now().isoformat()
        base_tweet['sentiment_label'] = None  # To be labeled
        expanded_tweets.append(base_tweet)
    
    output_data = {
        "metadata": {
            "collection_date": datetime.now().isoformat(),
            "total_tweets": len(expanded_tweets),
            "source": "sample_dataset",
            "purpose": "Training dataset (sample data for testing)",
            "status": "Unlabeled - ready for sentiment labeling",
            "note": "This is sample data. Replace with real collected tweets when possible."
        },
        "tweets": expanded_tweets
    }
    
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Created sample dataset with {len(expanded_tweets)} tweets")
    print(f"💾 Saved to: {output_path}")
    print("\n📝 Next steps:")
    print("   1. Preprocess: python scripts/preprocess_tweets.py")
    print("   2. Label tweets with sentiment (edit JSON file)")
    print("   3. Train model: python scripts/train_model.py")
    
    return output_path

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', '-o', default='data/tweets_snscrape.json')
    parser.add_argument('--num_tweets', '-n', type=int, default=300)
    args = parser.parse_args()
    
    create_sample_dataset(args.output, args.num_tweets)

