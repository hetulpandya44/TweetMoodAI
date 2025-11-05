"""
FastAPI Backend for TweetMoodAI
Provides API endpoints for tweet sentiment analysis using fine-tuned DistilBERT model
"""
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, validator
from typing import List, Optional
import os
import time
from dotenv import load_dotenv
from app.monitoring import metrics

# Load environment variables
load_dotenv()

# Configure structured logging
try:
    from app.logging_config import logger
    logger.info("Using structured logging (loguru)")
except ImportError:
    # Fallback to standard logging if loguru not available
    import logging
    logging.basicConfig(
        level=os.getenv("LOG_LEVEL", "INFO").upper(),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    logger = logging.getLogger(__name__)
    logger.warning("loguru not available, using standard logging")

# API Configuration from environment
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))
DEBUG = os.getenv("DEBUG", "False").lower() == "true"

app = FastAPI(
    title="TweetMoodAI API",
    description="AI-powered sentiment analysis API for Twitter data using fine-tuned DistilBERT",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    debug=DEBUG
)

# CORS middleware configuration
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS if "*" not in CORS_ORIGINS else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request/Response Models
class TweetRequest(BaseModel):
    tweet_text: str = Field(
        ..., 
        min_length=1, 
        max_length=1000, 
        description="Tweet text to analyze (1-1000 characters)"
    )
    
    @validator('tweet_text')
    def validate_tweet_text(cls, v):
        """Validate tweet text is not empty."""
        if not v or not v.strip():
            raise ValueError("tweet_text cannot be empty or whitespace only")
        if len(v) > 1000:
            raise ValueError("tweet_text cannot exceed 1000 characters")
        return v.strip()

class SentimentResponse(BaseModel):
    tweet_text: str = Field(..., description="Original tweet text")
    sentiment: str = Field(..., description="Sentiment label: positive, negative, or neutral")
    confidence: float = Field(..., ge=0.0, le=1.0, description="Confidence score between 0 and 1")
    label: str = Field(..., description="Short label: POS, NEG, or NEU")
    processing_time_ms: Optional[float] = Field(None, description="Processing time in milliseconds")

class BatchTweetRequest(BaseModel):
    tweets: List[str] = Field(
        ..., 
        min_items=1, 
        max_items=100, 
        description="List of tweet texts to analyze (max 100 tweets per batch)"
    )
    
    @validator('tweets')
    def validate_tweets(cls, v):
        """Validate batch of tweets."""
        if not v:
            raise ValueError("tweets list cannot be empty")
        if len(v) > 100:
            raise ValueError("Maximum 100 tweets per batch request")
        
        # Filter and validate individual tweets
        valid_tweets = []
        for i, tweet in enumerate(v):
            if not tweet or not isinstance(tweet, str):
                raise ValueError(f"Tweet at index {i} must be a non-empty string")
            tweet_stripped = tweet.strip()
            if not tweet_stripped:
                raise ValueError(f"Tweet at index {i} is empty or whitespace only")
            if len(tweet_stripped) > 1000:
                raise ValueError(f"Tweet at index {i} exceeds 1000 characters")
            valid_tweets.append(tweet_stripped)
        
        if not valid_tweets:
            raise ValueError("No valid tweets found in the list")
        
        return valid_tweets

class BatchSentimentResponse(BaseModel):
    results: List[SentimentResponse] = Field(..., description="List of sentiment analysis results")
    total_processed: int = Field(..., description="Total number of tweets processed")
    processing_time_ms: float = Field(..., description="Total processing time in milliseconds")
    average_time_per_tweet_ms: Optional[float] = Field(None, description="Average processing time per tweet")

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information."""
    from app.sentiment_analyzer import get_model
    model_data = get_model()
    
    return {
        "message": "TweetMoodAI API",
        "version": "1.0.0",
        "status": "running",
        "model": "DistilBERT-base-uncased",
        "model_loaded": model_data is not None,
        "endpoints": {
            "predict": "/predict",
            "predict_batch": "/predict/batch",
            "analyze": "/analyze (deprecated)",
            "analyze_batch": "/analyze/batch (deprecated)",
            "health": "/health",
            "healthz": "/healthz",
            "docs": "/docs"
        }
    }

# Health check endpoints
@app.get("/health")
async def health_check():
    """Health check endpoint with detailed status."""
    try:
        from app.sentiment_analyzer import get_model
        model_data = get_model()
        
        return {
            "status": "healthy",
            "model_loaded": model_data is not None,
            "timestamp": time.time(),
            "version": "1.0.0"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "status": "unhealthy",
                "error": str(e),
                "timestamp": time.time()
            }
        )

@app.get("/healthz")
async def healthz():
    """
    Kubernetes-style healthz endpoint for health checks.
    Returns 200 OK if healthy, 503 Service Unavailable if unhealthy.
    Simple status response for load balancer/proxy health checks.
    """
    try:
        from app.sentiment_analyzer import get_model
        model_data = get_model()
        
        if model_data is None:
            return JSONResponse(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                content={"status": "unhealthy", "reason": "Model not loaded"}
            )
        
        return {"status": "ok"}
    except Exception as e:
        logger.error(f"Healthz check failed: {e}")
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"status": "unhealthy", "error": str(e)}
        )

# Main prediction endpoint (optimized for low latency)
@app.post("/predict", response_model=SentimentResponse, status_code=status.HTTP_200_OK)
async def predict_sentiment(request: TweetRequest):
    """
    Predict sentiment of a single tweet using fine-tuned DistilBERT model.
    
    This endpoint is optimized for low latency inference.
    
    Args:
        request: JSON payload with tweet_text field (1-1000 characters)
    
    Returns:
        Sentiment analysis result with sentiment label and confidence score
    
    Example Request:
        ```json
        {
            "tweet_text": "This AI technology is amazing!"
        }
        ```
    
    Example Response:
        ```json
        {
            "tweet_text": "This AI technology is amazing!",
            "sentiment": "positive",
            "confidence": 0.95,
            "label": "POS",
            "processing_time_ms": 45.2
        }
        ```
    """
    start_time = time.time()
    
    try:
        from app.sentiment_analyzer import analyze_text
        
        # Analyze sentiment using trained model
        result = analyze_text(request.tweet_text)
        
        # Calculate processing time
        processing_time = (time.time() - start_time) * 1000  # Convert to milliseconds
        
        # Record metrics
        metrics.record_request(
            endpoint="/predict",
            latency_ms=processing_time,
            sentiment=result['sentiment'],
            success=True
        )
        
        return SentimentResponse(
            tweet_text=request.tweet_text,
            sentiment=result['sentiment'],
            confidence=round(result['confidence'], 4),
            label=result['label'],
            processing_time_ms=round(processing_time, 2)
        )
        
    except ValueError as e:
        logger.warning(f"Validation error: {e}")
        metrics.record_error("/predict", str(e))
        metrics.record_request("/predict", (time.time() - start_time) * 1000, success=False)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid input: {str(e)}"
        )
    except Exception as e:
        logger.error(f"Error analyzing sentiment: {e}", exc_info=True)
        metrics.record_error("/predict", str(e))
        metrics.record_request("/predict", (time.time() - start_time) * 1000, success=False)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error while analyzing sentiment. Please try again later."
        )

# Batch prediction endpoint (optimized for efficiency)
@app.post("/predict/batch", response_model=BatchSentimentResponse, status_code=status.HTTP_200_OK)
async def predict_batch(request: BatchTweetRequest):
    """
    Predict sentiment of multiple tweets in batch (optimized for efficiency).
    
    Processes up to 100 tweets per request. Use this endpoint for analyzing
    multiple tweets efficiently.
    
    Args:
        request: JSON payload with tweets list (1-100 tweets)
    
    Returns:
        List of sentiment analysis results with total processing time
    
    Example Request:
        ```json
        {
            "tweets": [
                "This is great!",
                "I hate this.",
                "The weather is okay today."
            ]
        }
        ```
    
    Example Response:
        ```json
        {
            "results": [
                {
                    "tweet_text": "This is great!",
                    "sentiment": "positive",
                    "confidence": 0.92,
                    "label": "POS"
                },
                ...
            ],
            "total_processed": 3,
            "processing_time_ms": 120.5,
            "average_time_per_tweet_ms": 40.17
        }
        ```
    """
    start_time = time.time()
    
    try:
        from app.sentiment_analyzer import analyze_text
        
        # Process all tweets
        results = []
        for tweet_text in request.tweets:
            try:
                result = analyze_text(tweet_text)
                results.append(SentimentResponse(
                    tweet_text=tweet_text,
                    sentiment=result['sentiment'],
                    confidence=round(result['confidence'], 4),
                    label=result['label']
                ))
            except Exception as e:
                logger.error(f"Error processing tweet '{tweet_text[:50]}...': {e}")
                # Continue processing other tweets even if one fails
                results.append(SentimentResponse(
                    tweet_text=tweet_text,
                    sentiment="neutral",
                    confidence=0.0,
                    label="NEU"
                ))
        
        processing_time = (time.time() - start_time) * 1000
        avg_time = processing_time / len(results) if results else 0
        
        # Record metrics for batch
        metrics.record_request(
            endpoint="/predict/batch",
            latency_ms=processing_time,
            success=True
        )
        # Record sentiment counts from batch
        for result in results:
            metrics.record_request(
                endpoint="/predict/batch",
                latency_ms=avg_time,
                sentiment=result.sentiment,
                success=True
            )
        
        return BatchSentimentResponse(
            results=results,
            total_processed=len(results),
            processing_time_ms=round(processing_time, 2),
            average_time_per_tweet_ms=round(avg_time, 2)
        )
        
    except ValueError as e:
        logger.warning(f"Validation error: {e}")
        metrics.record_error("/predict/batch", str(e))
        metrics.record_request("/predict/batch", (time.time() - start_time) * 1000, success=False)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid input: {str(e)}"
        )
    except Exception as e:
        logger.error(f"Error analyzing batch: {e}", exc_info=True)
        metrics.record_error("/predict/batch", str(e))
        metrics.record_request("/predict/batch", (time.time() - start_time) * 1000, success=False)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error while analyzing batch. Please try again later."
        )

# Legacy endpoints (for backward compatibility)
@app.post("/analyze", response_model=SentimentResponse, deprecated=True)
async def analyze_sentiment(request: TweetRequest):
    """
    Legacy endpoint - use /predict instead.
    
    This endpoint is deprecated and will be removed in a future version.
    Please migrate to /predict endpoint.
    """
    return await predict_sentiment(request)

@app.post("/analyze/batch", response_model=BatchSentimentResponse, deprecated=True)
async def analyze_batch(request: BatchTweetRequest):
    """
    Legacy endpoint - use /predict/batch instead.
    
    This endpoint is deprecated and will be removed in a future version.
    Please migrate to /predict/batch endpoint.
    """
    return await predict_batch(request)

# Monitoring endpoint
@app.get("/metrics")
async def get_metrics():
    """
    Get application metrics and monitoring data.
    
    Returns:
        Dictionary containing:
        - uptime_seconds: Total uptime
        - total_requests: Total number of requests
        - total_errors: Total number of errors
        - error_rate: Error rate percentage
        - avg_latency_ms: Average request latency
        - p95_latency_ms: 95th percentile latency
        - sentiment_distribution: Count of each sentiment
        - endpoint_usage: Usage count per endpoint
        - recent_errors: Last 10 errors
    """
    return metrics.get_stats()

@app.get("/metrics/sentiment-timeseries")
async def get_sentiment_timeseries(hours: int = 24):
    """
    Get sentiment distribution over time.
    
    Args:
        hours: Number of hours to look back (default: 24)
    
    Returns:
        List of sentiment counts over time
    """
    return metrics.get_sentiment_timeseries(hours=hours)

# Startup event
@app.on_event("startup")
async def startup_event():
    """Initialize model on startup for faster first inference."""
    logger.info("Starting TweetMoodAI API...")
    logger.info(f"Environment: {'DEBUG' if DEBUG else 'PRODUCTION'}")
    
    # Pre-load model to reduce first request latency
    try:
        from app.sentiment_analyzer import get_model
        logger.info("Pre-loading model...")
        model_data = get_model()
        if model_data:
            logger.info("✅ Model loaded successfully on startup")
        else:
            logger.warning("⚠️  Model not loaded - will use placeholder")
    except Exception as e:
        logger.error(f"Error loading model on startup: {e}")
        logger.warning("Will attempt to load on first request")

# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown."""
    logger.info("Shutting down TweetMoodAI API...")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host=API_HOST, 
        port=API_PORT,
        log_level=os.getenv("LOG_LEVEL", "info").lower()
    )
