"""
Streamlit Frontend for TweetMoodAI
Interactive web interface for sentiment analysis
Features:
- Single tweet analysis
- Batch analysis
- CSV/JSON file upload and processing
- Async API calls
- Comprehensive error handling
"""
import streamlit as st
import requests
import json
import os
from pathlib import Path
from typing import List, Dict, Optional, Tuple
import pandas as pd
from dotenv import load_dotenv
import time

# Load environment variables
load_dotenv()

# Page configuration
st.set_page_config(
    page_title="TweetMoodAI - Sentiment Analysis",
    page_icon="😊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# API endpoint configuration from environment variables
API_URL = os.getenv("API_URL", os.getenv("FASTAPI_URL", "http://localhost:8000"))
API_TIMEOUT = int(os.getenv("API_TIMEOUT", "30"))  # Default 30 seconds

# Custom CSS
st.markdown("""
    <style>
    .main-header {
        font-size: 3rem;
        font-weight: bold;
        color: #1DA1F2;
        text-align: center;
        margin-bottom: 2rem;
    }
    .sentiment-positive {
        color: #00AA00;
        font-weight: bold;
        font-size: 1.2rem;
    }
    .sentiment-negative {
        color: #FF4444;
        font-weight: bold;
        font-size: 1.2rem;
    }
    .sentiment-neutral {
        color: #FFA500;
        font-weight: bold;
        font-size: 1.2rem;
    }
    .stProgress > div > div > div > div {
        background-color: #1DA1F2;
    }
    .metric-container {
        padding: 1rem;
        border-radius: 0.5rem;
        background-color: #f0f2f6;
    }
    </style>
""", unsafe_allow_html=True)

# Session state initialization
if 'api_url' not in st.session_state:
    st.session_state.api_url = API_URL
if 'last_results' not in st.session_state:
    st.session_state.last_results = None

def check_api_health(api_url: Optional[str] = None) -> Tuple[bool, Optional[str]]:
    """
    Check if API is running and healthy.
    
    Returns:
        Tuple of (is_healthy, error_message)
    """
    url: str = api_url or st.session_state.get('api_url', API_URL) or API_URL
    try:
        response = requests.get(f"{url}/healthz", timeout=5)
        if response.status_code == 200:
            return True, None
        else:
            return False, f"API returned status {response.status_code}"
    except requests.exceptions.ConnectionError:
        return False, f"Could not connect to API at {url}"
    except requests.exceptions.Timeout:
        return False, "API health check timeout"
    except Exception as e:
        return False, str(e)

def analyze_sentiment(text: str, api_url: Optional[str] = None) -> Optional[Dict]:
    """
    Call API to analyze sentiment using /predict endpoint.
    
    Args:
        text: Tweet text to analyze
        api_url: Optional API URL override
    
    Returns:
        Analysis result dict or None if error
    """
    url: str = api_url or st.session_state.get('api_url', API_URL) or API_URL
    
    # Input validation
    if not text or not isinstance(text, str):
        st.error("❌ Invalid input: Text must be a non-empty string")
        return None
    
    text = text.strip()
    if not text:
        st.error("❌ Invalid input: Text cannot be empty or whitespace only")
        return None
    
    if len(text) > 1000:
        st.warning(f"⚠️ Text exceeds 1000 characters. Truncating to first 1000 characters.")
        text = text[:1000]
    
    try:
        response = requests.post(
            f"{url}/predict",
            json={"tweet_text": text},
            timeout=API_TIMEOUT,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 400:
            error_data = response.json()
            error_msg = error_data.get('detail', 'Invalid input')
            st.error(f"❌ Validation Error: {error_msg}")
            return None
        elif response.status_code == 503:
            st.error("❌ API Service Unavailable: Model may not be loaded")
            return None
        else:
            st.error(f"❌ API Error ({response.status_code}): {response.text}")
            return None
            
    except requests.exceptions.Timeout:
        st.error(f"⏱️ Request timeout - API took longer than {API_TIMEOUT} seconds to respond")
        return None
    except requests.exceptions.ConnectionError:
        st.error(f"🔌 Connection error - Could not connect to API at {url}")
        st.info("💡 Make sure the FastAPI server is running: `uvicorn app.main:app --reload`")
        return None
    except Exception as e:
        st.error(f"❌ Unexpected error: {str(e)}")
        return None

def analyze_batch(tweets: List[str], api_url: Optional[str] = None) -> Optional[Dict]:
    """
    Analyze multiple tweets using /predict/batch endpoint.
    
    Args:
        tweets: List of tweet texts
        api_url: Optional API URL override
    
    Returns:
        Batch analysis result dict or None if error
    """
    url: str = api_url or st.session_state.get('api_url', API_URL) or API_URL
    
    # Input validation
    if not tweets or not isinstance(tweets, list):
        st.error("❌ Invalid input: Tweets must be a non-empty list")
        return None
    
    if len(tweets) == 0:
        st.error("❌ Invalid input: Tweets list is empty")
        return None
    
    if len(tweets) > 100:
        st.warning(f"⚠️ Too many tweets ({len(tweets)}). Limiting to first 100.")
        tweets = tweets[:100]
    
    # Validate each tweet
    valid_tweets = []
    for i, tweet in enumerate(tweets):
        if not isinstance(tweet, str):
            st.warning(f"⚠️ Skipping non-string tweet at index {i}")
            continue
        tweet = tweet.strip()
        if tweet and len(tweet) <= 1000:
            valid_tweets.append(tweet)
        elif tweet:
            st.warning(f"⚠️ Skipping tweet {i+1}: exceeds 1000 characters")
    
    if not valid_tweets:
        st.error("❌ No valid tweets found after validation")
        return None
    
    try:
        response = requests.post(
            f"{url}/predict/batch",
            json={"tweets": valid_tweets},
            timeout=max(API_TIMEOUT * len(valid_tweets) // 10, 60),  # Dynamic timeout
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 400:
            error_data = response.json()
            error_msg = error_data.get('detail', 'Invalid input')
            st.error(f"❌ Validation Error: {error_msg}")
            return None
        elif response.status_code == 503:
            st.error("❌ API Service Unavailable: Model may not be loaded")
            return None
        else:
            st.error(f"❌ API Error ({response.status_code}): {response.text}")
            return None
            
    except requests.exceptions.Timeout:
        st.error(f"⏱️ Request timeout - Batch processing took too long")
        return None
    except requests.exceptions.ConnectionError:
        st.error(f"🔌 Connection error - Could not connect to API at {url}")
        st.info("💡 Make sure the FastAPI server is running: `uvicorn app.main:app --reload`")
        return None
    except Exception as e:
        st.error(f"❌ Unexpected error: {str(e)}")
        return None

def load_tweets_from_json(file_path: Path) -> List[Dict]:
    """Load tweets from JSON file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if isinstance(data, dict):
            if 'tweets' in data:
                tweets = data['tweets']
                if isinstance(tweets, list):
                    return [item if isinstance(item, dict) else {'text': str(item)} for item in tweets]
            elif 'data' in data:
                tweets = data['data']
                if isinstance(tweets, list):
                    return [item if isinstance(item, dict) else {'text': str(item)} for item in tweets]
            else:
                # Try to extract list from dict values
                for v in data.values():
                    if isinstance(v, list):
                        return [item if isinstance(item, dict) else {'text': str(item)} for item in v]
                return []
        elif isinstance(data, list):
            return [item if isinstance(item, dict) else {'text': str(item)} for item in data]
        return []
    except json.JSONDecodeError as e:
        st.error(f"❌ Invalid JSON file: {str(e)}")
        return []
    except Exception as e:
        st.error(f"❌ Error loading JSON file: {str(e)}")
        return []

def load_tweets_from_csv(file_path: Path) -> List[str]:
    """Load tweets from CSV file."""
    try:
        df = pd.read_csv(file_path)
        
        # Try common column names for tweet text
        text_columns = ['text', 'tweet_text', 'content', 'tweet', 'message', 'body']
        text_col = None
        
        for col in text_columns:
            if col in df.columns:
                text_col = col
                break
        
        if text_col is None:
            # Use first column if no match
            text_col = df.columns[0]
            st.info(f"ℹ️ Using column '{text_col}' for tweet text")
        
        # Extract non-null tweets
        tweets = df[text_col].dropna().astype(str).tolist()
        return tweets
    except Exception as e:
        st.error(f"❌ Error loading CSV file: {str(e)}")
        return []

def extract_tweet_texts(data: List[Dict]) -> List[str]:
    """Extract tweet texts from various data formats."""
    tweet_texts = []
    for item in data:
        if isinstance(item, dict):
            # Try common field names
            text = (item.get('cleaned_text') or 
                   item.get('content') or 
                   item.get('text') or 
                   item.get('tweet_text') or
                   item.get('tweet') or
                   item.get('message') or
                   item.get('body') or
                   '')
            if text and isinstance(text, str) and text.strip():
                tweet_texts.append(text.strip())
        elif isinstance(item, str) and item.strip():
            tweet_texts.append(item.strip())
    return tweet_texts

def format_results_table(results: List[Dict]) -> pd.DataFrame:
    """Format analysis results into a DataFrame for display."""
    df_data = []
    for result in results:
        df_data.append({
            'Tweet Text': result.get('tweet_text', '')[:100] + '...' if len(result.get('tweet_text', '')) > 100 else result.get('tweet_text', ''),
            'Full Text': result.get('tweet_text', ''),
            'Sentiment': result.get('sentiment', 'neutral').upper(),
            'Label': result.get('label', 'NEU'),
            'Confidence': f"{result.get('confidence', 0):.2%}",
            'Confidence Score': result.get('confidence', 0)
        })
    return pd.DataFrame(df_data)

def main():
    # Header
    st.markdown('<h1 class="main-header">😊 TweetMoodAI</h1>', unsafe_allow_html=True)
    st.markdown("### AI-Powered Sentiment Analysis for Twitter Data")
    st.markdown("---")
    
    # Sidebar with settings and info
    with st.sidebar:
        st.header("⚙️ Settings")
        
        # API URL configuration
        api_url_input = st.text_input(
            "API Base URL", 
            value=st.session_state.api_url,
            help="Change this to point to a different API instance (local or cloud)"
        )
        if api_url_input != st.session_state.api_url:
            st.session_state.api_url = api_url_input
        
        # API Health Check
        st.markdown("---")
        st.subheader("🔍 API Status")
        api_healthy, error_msg = check_api_health()
        
        if api_healthy:
            st.success("✅ API is running")
        else:
            st.error(f"❌ API is not accessible")
            if error_msg:
                st.caption(f"Error: {error_msg}")
            st.info("💡 Start the API with:\n```bash\nuvicorn app.main:app --reload\n```")
        
        st.markdown("---")
        st.subheader("📊 About")
        st.info("""
        **TweetMoodAI** analyzes sentiment of Twitter content using a fine-tuned DistilBERT model.
        
        **Features:**
        - ✅ Single tweet analysis
        - ✅ Batch analysis
        - ✅ CSV/JSON file upload
        - ✅ Export results
        
        **Supported formats:**
        - CSV files with tweet text columns
        - JSON files with tweet data
        """)
        
        st.markdown("---")
        st.caption(f"API URL: `{st.session_state.api_url}`")
        st.caption(f"Timeout: {API_TIMEOUT}s")
    
    # Main content tabs
    tab1, tab2, tab3, tab4 = st.tabs(["🔍 Single Analysis", "📊 Batch Analysis", "📁 File Upload", "📈 Monitoring Dashboard"])
    
    # Tab 1: Single Tweet Analysis
    with tab1:
        st.header("Analyze Single Tweet")
        st.markdown("Enter a single tweet below to analyze its sentiment.")
        
        tweet_text = st.text_area(
            "Tweet Text",
            height=150,
            placeholder="Enter the tweet you want to analyze...",
            help="Enter up to 1000 characters. The text will be analyzed for sentiment.",
            max_chars=1000
        )
        
        col1, col2 = st.columns([1, 4])
        with col1:
            analyze_button = st.button("🚀 Analyze Sentiment", type="primary", use_container_width=True)
        with col2:
            char_count = st.caption(f"Characters: {len(tweet_text)}/1000")
        
        if analyze_button:
            if tweet_text.strip():
                with st.spinner("🔄 Analyzing sentiment..."):
                    start_time = time.time()
                    result = analyze_sentiment(tweet_text)
                    elapsed_time = time.time() - start_time
                
                if result:
                    st.success("✅ Analysis complete!")
                    
                    # Metrics display
                    col1, col2, col3, col4 = st.columns(4)
                    
                    with col1:
                        sentiment_emoji = {
                            'positive': '😊',
                            'negative': '😞',
                            'neutral': '😐'
                        }
                        emoji = sentiment_emoji.get(result['sentiment'], '😐')
                        st.metric("Sentiment", f"{emoji} {result['sentiment'].upper()}")
                    
                    with col2:
                        confidence_pct = result['confidence'] * 100
                        st.metric("Confidence", f"{confidence_pct:.1f}%")
                    
                    with col3:
                        st.metric("Label", result['label'])
                    
                    with col4:
                        proc_time = result.get('processing_time_ms', elapsed_time * 1000)
                        st.metric("Processing Time", f"{proc_time:.0f}ms")
                    
                    # Visual sentiment indicator
                    st.markdown("---")
                    sentiment_class = f"sentiment-{result['sentiment']}"
                    sentiment_emoji_display = {
                        'positive': '😊 Positive Sentiment',
                        'negative': '😞 Negative Sentiment',
                        'neutral': '😐 Neutral Sentiment'
                    }
                    st.markdown(
                        f'<p class="{sentiment_class}">{sentiment_emoji_display[result["sentiment"]]}</p>',
                        unsafe_allow_html=True
                    )
                    
                    # Confidence progress bar
                    st.progress(result['confidence'])
                    st.caption(f"Confidence: {result['confidence']:.2%}")
                    
                    # Store result
                    st.session_state.last_results = [result]
            else:
                st.warning("⚠️ Please enter a tweet to analyze.")
    
    # Tab 2: Batch Analysis
    with tab2:
        st.header("Batch Tweet Analysis")
        st.markdown("Enter multiple tweets (one per line) to analyze them all at once.")
        
        batch_text = st.text_area(
            "Tweets (one per line)",
            height=300,
            placeholder="Enter multiple tweets, one per line...\n\nExample:\nThis is great!\nI hate this.\nThe weather is okay.",
            help="Enter multiple tweets separated by newlines. Up to 100 tweets per batch."
        )
        
        if batch_text.strip():
            tweets_list = [line.strip() for line in batch_text.split('\n') if line.strip()]
            st.info(f"ℹ️ Found {len(tweets_list)} tweet(s) ready for analysis")
        
        col1, col2 = st.columns([1, 4])
        with col1:
            analyze_batch_button = st.button("🚀 Analyze Batch", type="primary", use_container_width=True)
        with col2:
            if batch_text.strip():
                tweet_count = len([line.strip() for line in batch_text.split('\n') if line.strip()])
                st.caption(f"Tweets ready: {tweet_count}")
        
        if analyze_batch_button:
            if batch_text.strip():
                tweets = [line.strip() for line in batch_text.split('\n') if line.strip()]
                
                if len(tweets) > 100:
                    st.warning(f"⚠️ Maximum 100 tweets per batch. Analyzing first 100.")
                    tweets = tweets[:100]
                
                with st.spinner(f"🔄 Analyzing {len(tweets)} tweet(s)..."):
                    results = analyze_batch(tweets)
                
                if results:
                    results_list = results.get('results', [])
                    st.success(f"✅ Analyzed {len(results_list)} tweet(s)!")
                    
                    # Batch statistics
                    if isinstance(results, dict):
                        st.markdown("### 📊 Batch Statistics")
                        col1, col2, col3 = st.columns(3)
                        
                        with col1:
                            if 'processing_time_ms' in results:
                                st.metric("Total Processing Time", f"{results['processing_time_ms']:.0f}ms")
                        
                        with col2:
                            if 'average_time_per_tweet_ms' in results:
                                st.metric("Avg Time/Tweet", f"{results['average_time_per_tweet_ms']:.0f}ms")
                        
                        with col3:
                            st.metric("Tweets Processed", results.get('total_processed', len(results_list)))
                    
                    # Sentiment distribution
                    if results_list:
                        sentiment_counts = {}
                        for r in results_list:
                            sent = r.get('sentiment', 'neutral')
                            sentiment_counts[sent] = sentiment_counts.get(sent, 0) + 1
                        
                        st.markdown("### 📈 Sentiment Distribution")
                        col1, col2 = st.columns([2, 1])
                        
                        with col1:
                            chart_data = pd.DataFrame({
                                'Sentiment': list(sentiment_counts.keys()),
                                'Count': list(sentiment_counts.values())
                            })
                            st.bar_chart(chart_data.set_index('Sentiment'))
                        
                        with col2:
                            for sent, count in sentiment_counts.items():
                                percentage = (count / len(results_list)) * 100
                                st.metric(sent.upper(), f"{count} ({percentage:.1f}%)")
                    
                    # Results table
                    st.markdown("### 📋 Results Table")
                    df = format_results_table(results_list)
                    st.dataframe(df, use_container_width=True, height=400)
                    
                    # Export options
                    st.markdown("### 💾 Export Results")
                    col1, col2 = st.columns(2)
                    
                    with col1:
                        csv_data = df.to_csv(index=False)
                        st.download_button(
                            label="📥 Download as CSV",
                            data=csv_data,
                            file_name=f"sentiment_results_{int(time.time())}.csv",
                            mime="text/csv",
                            use_container_width=True
                        )
                    
                    with col2:
                        json_data = json.dumps(results_list, indent=2)
                        st.download_button(
                            label="📥 Download as JSON",
                            data=json_data,
                            file_name=f"sentiment_results_{int(time.time())}.json",
                            mime="application/json",
                            use_container_width=True
                        )
                    
                    # Store results
                    st.session_state.last_results = results_list
            else:
                st.warning("⚠️ Please enter tweets to analyze.")
    
    # Tab 3: File Upload
    with tab3:
        st.header("Analyze from File")
        st.markdown("Upload a CSV or JSON file containing tweets for batch analysis.")
        
        uploaded_file = st.file_uploader(
            "Choose a file",
            type=['csv', 'json'],
            help="Upload a CSV file with tweet text columns, or a JSON file with tweet data"
        )
        
        if uploaded_file is not None:
            file_ext = uploaded_file.name.split('.')[-1].lower()
            temp_path = Path(f"temp_upload_{int(time.time())}.{file_ext}")
            
            # Save uploaded file temporarily
            try:
                with open(temp_path, 'wb') as f:
                    f.write(uploaded_file.read())
                
                st.success(f"✅ File uploaded: {uploaded_file.name} ({file_ext.upper()})")
                
                # Load data based on file type
                tweets_data = []
                tweet_texts = []
                
                if file_ext == 'json':
                    tweets_data = load_tweets_from_json(temp_path)
                    if tweets_data:
                        tweet_texts = extract_tweet_texts(tweets_data)
                        st.info(f"ℹ️ Loaded {len(tweets_data)} item(s), extracted {len(tweet_texts)} tweet(s)")
                
                elif file_ext == 'csv':
                    tweet_texts = load_tweets_from_csv(temp_path)
                    if tweet_texts:
                        st.info(f"ℹ️ Loaded {len(tweet_texts)} tweet(s) from CSV")
                
                # Process if we have tweets
                if tweet_texts:
                    st.markdown("### 📊 File Preview")
                    
                    # Show preview
                    preview_df = pd.DataFrame({'Tweet Text': tweet_texts[:10]})
                    st.dataframe(preview_df, use_container_width=True)
                    if len(tweet_texts) > 10:
                        st.caption(f"Showing first 10 of {len(tweet_texts)} tweets")
                    
                    # Analysis button
                    if st.button("🚀 Analyze All Tweets", type="primary", use_container_width=True):
                        # Process in batches if too many
                        if len(tweet_texts) > 100:
                            st.warning(f"⚠️ File contains {len(tweet_texts)} tweets. Processing in batches of 100.")
                            
                            all_results = []
                            total_batches = (len(tweet_texts) + 99) // 100
                            
                            progress_bar = st.progress(0)
                            status_text = st.empty()
                            
                            for i in range(0, len(tweet_texts), 100):
                                batch = tweet_texts[i:i+100]
                                batch_num = (i // 100) + 1
                                
                                status_text.text(f"Processing batch {batch_num}/{total_batches}...")
                                results = analyze_batch(batch)
                                
                                if results:
                                    all_results.extend(results.get('results', []))
                                
                                progress_bar.progress(min((i + 100) / len(tweet_texts), 1.0))
                            
                            status_text.empty()
                            progress_bar.empty()
                            
                            if all_results:
                                results = {'results': all_results, 'total_processed': len(all_results)}
                            else:
                                st.error("❌ Failed to process tweets")
                                results = None
                        else:
                            with st.spinner(f"🔄 Analyzing {len(tweet_texts)} tweet(s)..."):
                                results = analyze_batch(tweet_texts)
                        
                        if results:
                            results_list = results.get('results', [])
                            st.success(f"✅ Analyzed {len(results_list)} tweet(s)!")
                            
                            # Combine with original data if available
                            df = format_results_table(results_list)
                            if tweets_data and len(tweets_data) == len(results_list):
                                # Add original metadata
                                for i, orig in enumerate(tweets_data[:len(results_list)]):
                                    if isinstance(orig, dict):
                                        df.at[i, 'Original ID'] = orig.get('id', '')
                                        df.at[i, 'Date'] = orig.get('date', orig.get('created_at', ''))
                            
                            # Display results
                            st.markdown("### 📋 Analysis Results")
                            st.dataframe(df, use_container_width=True, height=400)
                            
                            # Sentiment distribution
                            sentiment_counts = {}
                            for r in results_list:
                                sent = r.get('sentiment', 'neutral')
                                sentiment_counts[sent] = sentiment_counts.get(sent, 0) + 1
                            
                            st.markdown("### 📈 Sentiment Distribution")
                            col1, col2 = st.columns([2, 1])
                            
                            with col1:
                                chart_data = pd.DataFrame({
                                    'Sentiment': list(sentiment_counts.keys()),
                                    'Count': list(sentiment_counts.values())
                                })
                                st.bar_chart(chart_data.set_index('Sentiment'))
                            
                            with col2:
                                for sent, count in sentiment_counts.items():
                                    percentage = (count / len(results_list)) * 100
                                    st.metric(sent.upper(), f"{count} ({percentage:.1f}%)")
                            
                            # Export results
                            st.markdown("### 💾 Export Results")
                            col1, col2 = st.columns(2)
                            
                            with col1:
                                csv_data = df.to_csv(index=False)
                                st.download_button(
                                    label="📥 Download as CSV",
                                    data=csv_data,
                                    file_name=f"sentiment_results_{int(time.time())}.csv",
                                    mime="text/csv",
                                    use_container_width=True
                                )
                            
                            with col2:
                                json_data = json.dumps(results_list, indent=2)
                                st.download_button(
                                    label="📥 Download as JSON",
                                    data=json_data,
                                    file_name=f"sentiment_results_{int(time.time())}.json",
                                    mime="application/json",
                                    use_container_width=True
                                )
                            
                            st.session_state.last_results = results_list
                else:
                    st.warning("⚠️ No tweet text found in file. Make sure the file contains tweet text in supported fields.")
            
            except Exception as e:
                st.error(f"❌ Error processing file: {str(e)}")
            
            finally:
                # Clean up temporary file
                if temp_path.exists():
                    try:
                        temp_path.unlink()
                    except:
                        pass
        else:
            st.info("📁 Upload a CSV or JSON file to analyze tweets")
            st.markdown("""
            **Supported formats:**
            - **CSV**: Files with columns named `text`, `tweet_text`, `content`, `tweet`, `message`, or `body`
            - **JSON**: Files with array of tweet objects or objects with `tweets` array
            """)
    
    # Tab 4: Monitoring Dashboard
    with tab4:
        st.header("📈 Monitoring Dashboard")
        st.markdown("Real-time metrics and system health monitoring")
        
        # Check if API is available
        api_healthy, api_error = check_api_health()
        
        if not api_healthy:
            st.error(f"❌ API is not available: {api_error}")
            st.info("Make sure the backend API is running to view monitoring data.")
        else:
            try:
                url: str = st.session_state.get('api_url', API_URL) or API_URL
                
                # Fetch metrics
                with st.spinner("Loading metrics..."):
                    metrics_response = requests.get(f"{url}/metrics", timeout=5)
                    
                    if metrics_response.status_code == 200:
                        metrics_data = metrics_response.json()
                        
                        # System Overview
                        st.markdown("### 🖥️ System Overview")
                        col1, col2, col3, col4 = st.columns(4)
                        
                        with col1:
                            uptime_hours = metrics_data.get('uptime_hours', 0)
                            st.metric("Uptime", f"{uptime_hours:.1f} hours")
                        
                        with col2:
                            total_requests = metrics_data.get('total_requests', 0)
                            st.metric("Total Requests", f"{total_requests:,}")
                        
                        with col3:
                            error_rate = metrics_data.get('error_rate', 0)
                            st.metric("Error Rate", f"{error_rate:.2f}%")
                        
                        with col4:
                            avg_latency = metrics_data.get('avg_latency_ms', 0)
                            st.metric("Avg Latency", f"{avg_latency:.1f}ms")
                        
                        # Performance Metrics
                        st.markdown("### ⚡ Performance Metrics")
                        col1, col2 = st.columns(2)
                        
                        with col1:
                            p95_latency = metrics_data.get('p95_latency_ms', 0)
                            st.metric("P95 Latency", f"{p95_latency:.1f}ms")
                        
                        with col2:
                            total_errors = metrics_data.get('total_errors', 0)
                            st.metric("Total Errors", f"{total_errors}")
                        
                        # Sentiment Distribution
                        st.markdown("### 📊 Sentiment Distribution")
                        sentiment_dist = metrics_data.get('sentiment_distribution', {})
                        
                        if sentiment_dist:
                            col1, col2 = st.columns([2, 1])
                            
                            with col1:
                                chart_data = pd.DataFrame({
                                    'Sentiment': list(sentiment_dist.keys()),
                                    'Count': list(sentiment_dist.values())
                                })
                                st.bar_chart(chart_data.set_index('Sentiment'))
                            
                            with col2:
                                total_sentiments = sum(sentiment_dist.values())
                                for sentiment, count in sentiment_dist.items():
                                    percentage = (count / total_sentiments * 100) if total_sentiments > 0 else 0
                                    st.metric(
                                        sentiment.upper(),
                                        f"{count:,} ({percentage:.1f}%)"
                                    )
                        else:
                            st.info("No sentiment data yet. Make some predictions to see distribution.")
                        
                        # Endpoint Usage
                        st.markdown("### 🔌 Endpoint Usage")
                        endpoint_usage = metrics_data.get('endpoint_usage', {})
                        
                        if endpoint_usage:
                            usage_df = pd.DataFrame({
                                'Endpoint': list(endpoint_usage.keys()),
                                'Requests': list(endpoint_usage.values())
                            }).sort_values('Requests', ascending=False)
                            st.dataframe(usage_df, use_container_width=True, hide_index=True)
                        else:
                            st.info("No endpoint usage data yet.")
                        
                        # Recent Errors
                        recent_errors = metrics_data.get('recent_errors', [])
                        if recent_errors:
                            st.markdown("### ⚠️ Recent Errors")
                            with st.expander(f"View {len(recent_errors)} recent errors"):
                                for error in recent_errors:
                                    st.error(f"**{error.get('endpoint', 'Unknown')}** - {error.get('error', 'Unknown error')}")
                                    st.caption(f"Time: {error.get('timestamp', 'Unknown')}")
                                    st.markdown("---")
                        else:
                            st.success("✅ No recent errors!")
                        
                        # Refresh button
                        if st.button("🔄 Refresh Metrics", use_container_width=True):
                            st.rerun()
                    else:
                        st.error(f"Failed to fetch metrics: {metrics_response.status_code}")
            
            except Exception as e:
                st.error(f"Error loading monitoring data: {str(e)}")
                st.info("Make sure the backend API is running and accessible.")

if __name__ == "__main__":
    main()
