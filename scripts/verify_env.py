"""
Script to verify that environment variables are properly loaded.
Run this to check if your .env file is configured correctly.
"""
import os
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(env_path)

def verify_env_vars():
    """Check if required environment variables are set."""
    required_vars = [
        'TWITTER_API_KEY',
        'TWITTER_API_SECRET',
        'TWITTER_ACCESS_TOKEN',
        'TWITTER_ACCESS_TOKEN_SECRET',
    ]
    
    # Check bearer token (either X_BEARER_TOKEN or TWITTER_BEARER_TOKEN)
    bearer_token_vars = ['X_BEARER_TOKEN', 'TWITTER_BEARER_TOKEN']
    
    print("=" * 50)
    print("Environment Variables Verification")
    print("=" * 50)
    
    all_set = True
    for var in required_vars:
        value = os.getenv(var)
        if value and value not in ['your_api_key_here', 'your_api_secret_here', 
                                   'your_access_token_here', 'your_access_token_secret_here']:
            # Mask the value for security (show first 4 and last 4 chars)
            masked = value[:4] + '*' * (len(value) - 8) + value[-4:] if len(value) > 8 else '****'
            print(f"✅ {var}: {masked}")
        else:
            print(f"❌ {var}: NOT SET or still using placeholder")
            all_set = False
    
    # Check bearer token (either X_BEARER_TOKEN or TWITTER_BEARER_TOKEN)
    bearer_token = os.getenv('X_BEARER_TOKEN') or os.getenv('TWITTER_BEARER_TOKEN')
    if bearer_token and bearer_token not in ['your_bearer_token_here']:
        masked = bearer_token[:4] + '*' * (len(bearer_token) - 8) + bearer_token[-4:] if len(bearer_token) > 8 else '****'
        print(f"✅ Bearer Token (X_BEARER_TOKEN or TWITTER_BEARER_TOKEN): {masked}")
    else:
        print(f"❌ Bearer Token: NOT SET (need either X_BEARER_TOKEN or TWITTER_BEARER_TOKEN)")
        all_set = False
    
    print("=" * 50)
    if all_set:
        print("✅ All Twitter API credentials are configured!")
    else:
        print("⚠️  Please update your .env file with actual API credentials")
    print("=" * 50)
    
    return all_set

if __name__ == "__main__":
    verify_env_vars()
