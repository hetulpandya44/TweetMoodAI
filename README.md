# TweetMoodAI

AI-powered sentiment analysis application for Twitter data.

## Project Structure

```
TweetMoodAI/
├── app/              # FastAPI backend application
├── data/             # Data storage (raw and processed)
├── models/           # Trained ML models
├── ui/               # Streamlit frontend
├── scripts/          # Utility scripts
├── tests/            # Test files
├── .github/          # GitHub workflows
│   └── workflows/    # CI/CD pipelines
├── requirements.txt  # Python dependencies
├── Dockerfile        # Docker configuration
├── docker-compose.yml # Docker Compose configuration
└── .env             # Environment variables (create from env.example)
```

## Setup Instructions

1. **Create virtual environment** (if not already done):
   ```bash
   python -m venv venv
   ```

2. **Activate virtual environment**:
   - Windows: `venv\Scripts\activate`
   - Linux/Mac: `source venv/bin/activate`

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**:
   ```bash
   # Windows PowerShell
   Copy-Item env.example .env
   
   # Linux/Mac
   cp env.example .env
   
   # Edit .env with your Twitter API credentials
   ```

5. **Run the application**:
   ```bash
   # FastAPI backend
   uvicorn app.main:app --reload
   
   # Streamlit frontend
   streamlit run ui/app.py
   ```

## Requirements

- Python 3.10+
- Docker Desktop (optional, for containerized deployment)
- Git
- VS Code with Python extensions (recommended)

## Environment Variables

See `env.example` for required environment variables.

**Important**: Before using the Twitter API, ensure your Developer App is attached to a Project. See [TWITTER_API_SETUP.md](TWITTER_API_SETUP.md) for detailed setup instructions.

## Tweet Collection

### Strategy: Training vs Presentation

**For Training Data (Recommended)**: Use `snscrape` - **No API limits!**
```bash
# Collect thousands of tweets for training (no limits)
python scripts/fetch_tweets_snscrape.py --hashtag "AI" --max_tweets 5000
```

**For Presentation/Demo**: Use official Twitter API - **Professional appearance**
```bash
# Use official API for presentations (respects API limits)
python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 10
```

### Option 1: Using snscrape (Training - No Limits)

Perfect for collecting large datasets for model training - **NO API LIMITS!**

```bash
# Large collection for training (unlimited!)
python scripts/fetch_tweets_snscrape.py --hashtag "AI" --max_tweets 5000

# With date range
python scripts/fetch_tweets_snscrape.py --query "machine learning" --max_tweets 2000 --since 2024-01-01

# User tweets
python scripts/fetch_tweets_snscrape.py --user "elonmusk" --max_tweets 1000

# Custom output
python scripts/fetch_tweets_snscrape.py --hashtag "AI" --max_tweets 5000 --output data/training_ai.json
```

**Advantages:**
- ✅ Unlimited collection (perfect for training)
- ✅ No API quotas
- ✅ Fast data collection
- ✅ Free to use

### Option 2: Using Official Twitter API (Presentation)

For professional presentations and demos - **Official API!**

```bash
# Professional demo with official API
python scripts/fetch_twitter_api.py --query "#AI" --max_tweets 10

# Hashtag search
python scripts/fetch_twitter_api.py --hashtag "AI" --max_tweets 10

# User search
python scripts/fetch_twitter_api.py --user "elonmusk" --max_tweets 10
```

**Advantages:**
- ✅ Official API (professional)
- ✅ Production-ready
- ✅ Reliable access

**Note**: 
- Ensure your `.env` file contains `X_BEARER_TOKEN` or `TWITTER_BEARER_TOKEN` and that your Twitter Developer App is attached to a Project (see [TWITTER_API_SETUP.md](TWITTER_API_SETUP.md)).
- **Free Tier Users**: You have **100 tweets per month limit**. See [TWITTER_API_LIMITS.md](TWITTER_API_LIMITS.md) for details.

## Training Dataset Preparation

**For model training, use snscrape to avoid API limits!**

### Step 1: Collect Training Data (300+ tweets)

```bash
# Collect 500+ tweets for training (no limits!)
python scripts/fetch_snscrape.py --hashtag "AI" --max_tweets 500

# With date range
python scripts/fetch_snscrape.py --hashtag "sentiment" --max_tweets 300 --since 2024-01-01
```

**Output**: `data/tweets_snscrape.json` - Raw tweets ready for preprocessing

### Step 2: Preprocess Tweets

Clean text by removing URLs, mentions, hashtags, and converting emojis:

```bash
# Preprocess collected tweets
python scripts/preprocess_tweets.py

# Custom input/output
python scripts/preprocess_tweets.py --input data/tweets_snscrape.json --output data/tweets_cleaned.json
```

**Preprocessing steps**:
- ✅ Remove URLs (http://, https://, www.)
- ✅ Remove @mentions
- ✅ Remove #hashtags (symbols removed, words kept)
- ✅ Convert emojis to text (😊 → "smiling_face")
- ✅ Clean whitespace

**Output**: `data/tweets_snscrape_cleaned.json` - Cleaned tweets ready for labeling

### Step 3: Label with Sentiment

Manually or semi-automatically add sentiment labels (`positive`, `negative`, `neutral`) to each tweet.

### Step 4: Train Model

Use the labeled, preprocessed data to train your sentiment analysis model.

**See [TRAINING_DATA_PREP.md](TRAINING_DATA_PREP.md) for complete workflow details.**

## Docker Deployment

### Prerequisites

- Docker Desktop installed and running
- Docker Compose installed (included with Docker Desktop)

### Verify Docker Setup

```bash
# Run verification script
python scripts/verify_docker.py

# Or manually check
docker --version
docker compose version
```

### Start Docker Desktop (if not running)

```bash
# PowerShell script (Windows)
powershell -ExecutionPolicy Bypass -File scripts\start_docker.ps1

# Or batch file (Windows)
scripts\start_docker.bat

# Or start manually from Start Menu
```

### Local Docker Deployment

#### Step 1: Build Docker Images

```bash
# Build all services
docker-compose build

# Or build specific service
docker-compose build backend
docker-compose build frontend
```

#### Step 2: Start Services

```bash
# Start all services in detached mode
docker-compose up -d

# Or start with logs visible
docker-compose up
```

#### Step 3: Access Services

- **FastAPI Backend**: http://localhost:8000
  - API Docs: http://localhost:8000/docs
  - Health Check: http://localhost:8000/healthz

- **Streamlit Frontend**: http://localhost:8501

#### Step 4: View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

#### Step 5: Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ removes data)
docker-compose down -v
```

### Docker Configuration

- **Backend**: Multi-stage Dockerfile (`Dockerfile.backend`)
- **Frontend**: Separate Dockerfile (`Dockerfile.frontend`)
- **Orchestration**: `docker-compose.yml` manages both services
- **Volumes**: Models and data persist across container restarts
- **Networking**: Services communicate via internal Docker network

**Note**: Cloud deployment is pending and will be done at the end of the project. See [PENDING_TASKS.md](PENDING_TASKS.md) for details.

For detailed Docker documentation, see [STEP7_COMPLETE.md](STEP7_COMPLETE.md).

## License

[Add your license here]
