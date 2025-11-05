"""
Monitoring and metrics collection for TweetMoodAI
Tracks API requests, latencies, sentiment distributions, and system health
"""
import time
from typing import Dict, List, Optional
from collections import defaultdict, deque
from datetime import datetime, timedelta
from pathlib import Path
import json

class MetricsCollector:
    """Collects and stores application metrics"""
    
    def __init__(self, max_history: int = 1000):
        self.max_history = max_history
        self.request_count = 0
        self.error_count = 0
        self.start_time = time.time()
        
        # Request latencies (milliseconds)
        self.latencies: deque = deque(maxlen=max_history)
        
        # Sentiment distribution
        self.sentiment_counts: Dict[str, int] = defaultdict(int)
        
        # Error tracking
        self.errors: deque = deque(maxlen=100)
        
        # Endpoint usage
        self.endpoint_usage: Dict[str, int] = defaultdict(int)
        
    def record_request(
        self, 
        endpoint: str, 
        latency_ms: float, 
        sentiment: Optional[str] = None,
        success: bool = True
    ):
        """Record a request and its metrics"""
        self.request_count += 1
        self.latencies.append(latency_ms)
        self.endpoint_usage[endpoint] += 1
        
        if not success:
            self.error_count += 1
        
        if sentiment:
            self.sentiment_counts[sentiment] += 1
    
    def record_error(self, endpoint: str, error: str):
        """Record an error"""
        self.errors.append({
            "timestamp": datetime.utcnow().isoformat(),
            "endpoint": endpoint,
            "error": error
        })
    
    def get_stats(self) -> Dict:
        """Get current statistics"""
        latencies_list = list(self.latencies)
        avg_latency = sum(latencies_list) / len(latencies_list) if latencies_list else 0
        p95_latency = sorted(latencies_list)[int(len(latencies_list) * 0.95)] if latencies_list else 0
        
        uptime_seconds = time.time() - self.start_time
        uptime_hours = uptime_seconds / 3600
        
        return {
            "uptime_seconds": uptime_seconds,
            "uptime_hours": round(uptime_hours, 2),
            "total_requests": self.request_count,
            "total_errors": self.error_count,
            "error_rate": round(self.error_count / self.request_count * 100, 2) if self.request_count > 0 else 0,
            "avg_latency_ms": round(avg_latency, 2),
            "p95_latency_ms": round(p95_latency, 2),
            "sentiment_distribution": dict(self.sentiment_counts),
            "endpoint_usage": dict(self.endpoint_usage),
            "recent_errors": list(self.errors)[-10:]  # Last 10 errors
        }
    
    def get_sentiment_timeseries(self, hours: int = 24) -> List[Dict]:
        """Get sentiment distribution over time (simplified - returns current distribution)"""
        # In a production system, this would track time-series data
        # For now, return current distribution
        return [
            {
                "timestamp": datetime.utcnow().isoformat(),
                "sentiment": sentiment,
                "count": count
            }
            for sentiment, count in self.sentiment_counts.items()
        ]

# Global metrics collector instance
metrics = MetricsCollector()

__all__ = ["metrics", "MetricsCollector"]

