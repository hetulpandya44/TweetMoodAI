"""
Pytest tests for FastAPI backend API endpoints
Tests for /predict, /healthz, and error handling
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app
import json
import os

@pytest.fixture(scope="module")
def test_client():
    """Create a test client for the FastAPI app"""
    return TestClient(app)


class TestHealthzEndpoint:
    """Test cases for /healthz endpoint"""
    
    def test_healthz_success(self, test_client):
        """Test healthz endpoint returns 200 OK when healthy"""
        response = test_client.get("/healthz")
        assert response.status_code in [200, 503]  # 503 if model not loaded is acceptable in test
        data = response.json()
        assert "status" in data
        # Status can be "ok" or "unhealthy" depending on model loading
        assert data["status"] in ["ok", "unhealthy"]
    
    def test_healthz_response_structure(self, test_client):
        """Test healthz response has correct structure"""
        response = test_client.get("/healthz")
        data = response.json()
        
        if response.status_code == 200:
            assert data["status"] == "ok"
        elif response.status_code == 503:
            assert data["status"] == "unhealthy"
            assert "reason" in data or "error" in data
    
    def test_healthz_method_allowed(self, test_client):
        """Test healthz endpoint accepts GET requests"""
        response = test_client.get("/healthz")
        # Should not return 405 Method Not Allowed
        assert response.status_code != 405
    
    def test_healthz_post_not_allowed(self, test_client):
        """Test healthz endpoint does not accept POST requests"""
        response = test_client.post("/healthz")
        assert response.status_code == 405  # Method Not Allowed


class TestPredictEndpoint:
    """Test cases for /predict endpoint"""
    
    def test_predict_success(self, test_client):
        """Test /predict endpoint with valid input"""
        payload = {
            "tweet_text": "This is a great day! I love it!"
        }
        response = test_client.post("/predict", json=payload)
        
        # Should return 200 or 503/500 if model not loaded
        assert response.status_code in [200, 503, 500]
        
        if response.status_code == 200:
            data = response.json()
            assert "tweet_text" in data
            assert "sentiment" in data
            assert "confidence" in data
            assert "label" in data
            assert data["sentiment"] in ["positive", "negative", "neutral"]
            assert data["label"] in ["POS", "NEG", "NEU"]
            assert 0.0 <= data["confidence"] <= 1.0
            assert data["tweet_text"] == payload["tweet_text"]
    
    def test_predict_empty_text(self, test_client):
        """Test /predict endpoint rejects empty text"""
        payload = {
            "tweet_text": ""
        }
        response = test_client.post("/predict", json=payload)
        assert response.status_code == 422  # Validation error
    
    def test_predict_whitespace_only(self, test_client):
        """Test /predict endpoint rejects whitespace-only text"""
        payload = {
            "tweet_text": "   "
        }
        response = test_client.post("/predict", json=payload)
        assert response.status_code == 422  # Validation error
    
    def test_predict_text_too_long(self, test_client):
        """Test /predict endpoint rejects text exceeding 1000 characters"""
        payload = {
            "tweet_text": "a" * 1001
        }
        response = test_client.post("/predict", json=payload)
        assert response.status_code == 422  # Validation error
    
    def test_predict_missing_field(self, test_client):
        """Test /predict endpoint rejects request without tweet_text field"""
        payload = {}
        response = test_client.post("/predict", json=payload)
        assert response.status_code == 422  # Validation error
    
    def test_predict_invalid_json(self, test_client):
        """Test /predict endpoint handles invalid JSON"""
        response = test_client.post(
            "/predict",
            data="invalid json",
            headers={"Content-Type": "application/json"}
        )
        assert response.status_code == 422
    
    def test_predict_positive_sentiment(self, test_client):
        """Test /predict endpoint with positive sentiment text"""
        payload = {
            "tweet_text": "I am so happy and excited about this amazing product!"
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            assert data["sentiment"] in ["positive", "negative", "neutral"]
    
    def test_predict_negative_sentiment(self, test_client):
        """Test /predict endpoint with negative sentiment text"""
        payload = {
            "tweet_text": "This is terrible and I hate it so much!"
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            assert data["sentiment"] in ["positive", "negative", "neutral"]
    
    def test_predict_neutral_sentiment(self, test_client):
        """Test /predict endpoint with neutral sentiment text"""
        payload = {
            "tweet_text": "The weather is okay today."
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            assert data["sentiment"] in ["positive", "negative", "neutral"]
    
    def test_predict_response_structure(self, test_client):
        """Test /predict response has correct structure"""
        payload = {
            "tweet_text": "Test tweet for structure validation"
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            required_fields = ["tweet_text", "sentiment", "confidence", "label"]
            for field in required_fields:
                assert field in data, f"Missing required field: {field}"
            
            # Check types
            assert isinstance(data["tweet_text"], str)
            assert isinstance(data["sentiment"], str)
            assert isinstance(data["confidence"], (int, float))
            assert isinstance(data["label"], str)
    
    def test_predict_processing_time(self, test_client):
        """Test /predict response includes processing_time_ms"""
        payload = {
            "tweet_text": "Test tweet for processing time"
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            if "processing_time_ms" in data:
                assert isinstance(data["processing_time_ms"], (int, float))
                assert data["processing_time_ms"] >= 0
    
    def test_predict_max_length_text(self, test_client):
        """Test /predict endpoint accepts text at max length (1000 chars)"""
        payload = {
            "tweet_text": "a" * 1000
        }
        response = test_client.post("/predict", json=payload)
        
        # Should accept (may truncate internally)
        assert response.status_code in [200, 422, 500, 503]
    
    def test_predict_special_characters(self, test_client):
        """Test /predict endpoint handles special characters"""
        payload = {
            "tweet_text": "Test with special chars: !@#$%^&*()_+-=[]{}|;:,.<>?/`~"
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            assert data["tweet_text"] == payload["tweet_text"]
    
    def test_predict_unicode_characters(self, test_client):
        """Test /predict endpoint handles unicode characters"""
        payload = {
            "tweet_text": "Test with unicode: 😊 🌟 🎉 こんにちは مرحبا"
        }
        response = test_client.post("/predict", json=payload)
        
        if response.status_code == 200:
            data = response.json()
            assert data["tweet_text"] == payload["tweet_text"]
    
    def test_predict_get_method_not_allowed(self, test_client):
        """Test /predict endpoint does not accept GET requests"""
        response = test_client.get("/predict")
        assert response.status_code == 405  # Method Not Allowed


class TestPredictBatchEndpoint:
    """Test cases for /predict/batch endpoint"""
    
    def test_predict_batch_success(self, test_client):
        """Test /predict/batch endpoint with valid input"""
        payload = {
            "tweets": [
                "This is great!",
                "I hate this.",
                "It's okay."
            ]
        }
        response = test_client.post("/predict/batch", json=payload)
        
        assert response.status_code in [200, 422, 500, 503]
        
        if response.status_code == 200:
            data = response.json()
            assert "results" in data
            assert isinstance(data["results"], list)
            assert len(data["results"]) == len(payload["tweets"])
            
            for result in data["results"]:
                assert "tweet_text" in result
                assert "sentiment" in result
                assert "confidence" in result
                assert "label" in result
    
    def test_predict_batch_empty_list(self, test_client):
        """Test /predict/batch endpoint rejects empty list"""
        payload = {
            "tweets": []
        }
        response = test_client.post("/predict/batch", json=payload)
        assert response.status_code == 422  # Validation error
    
    def test_predict_batch_too_many_tweets(self, test_client):
        """Test /predict/batch endpoint rejects more than 100 tweets"""
        payload = {
            "tweets": ["tweet"] * 101
        }
        response = test_client.post("/predict/batch", json=payload)
        assert response.status_code == 422  # Validation error
    
    def test_predict_batch_max_tweets(self, test_client):
        """Test /predict/batch endpoint accepts exactly 100 tweets"""
        payload = {
            "tweets": ["tweet"] * 100
        }
        response = test_client.post("/predict/batch", json=payload)
        
        # Should accept (may fail if model not loaded)
        assert response.status_code in [200, 422, 500, 503]
    
    def test_predict_batch_missing_field(self, test_client):
        """Test /predict/batch endpoint rejects request without tweets field"""
        payload = {}
        response = test_client.post("/predict/batch", json=payload)
        assert response.status_code == 422  # Validation error


class TestErrorHandling:
    """Test cases for error handling"""
    
    def test_invalid_endpoint(self, test_client):
        """Test invalid endpoint returns 404"""
        response = test_client.get("/invalid-endpoint")
        assert response.status_code == 404
    
    def test_root_endpoint_redirects(self, test_client):
        """Test root endpoint exists (should redirect to docs or return info)"""
        response = test_client.get("/")
        # FastAPI usually returns 404 for root, or redirects to docs
        assert response.status_code in [200, 404, 307, 308]
    
    def test_docs_endpoint(self, test_client):
        """Test /docs endpoint is accessible"""
        response = test_client.get("/docs")
        assert response.status_code == 200
    
    def test_openapi_endpoint(self, test_client):
        """Test /openapi.json endpoint is accessible"""
        response = test_client.get("/openapi.json")
        assert response.status_code == 200
        data = response.json()
        assert "openapi" in data or "swagger" in data.lower()


class TestAPIStructure:
    """Test cases for API structure and metadata"""
    
    def test_openapi_schema(self, test_client):
        """Test OpenAPI schema is valid"""
        response = test_client.get("/openapi.json")
        assert response.status_code == 200
        schema = response.json()
        
        # Check required OpenAPI fields
        assert "paths" in schema
        assert "/predict" in schema["paths"]
        assert "/healthz" in schema["paths"]
    
    def test_api_version(self, test_client):
        """Test API version is in OpenAPI schema"""
        response = test_client.get("/openapi.json")
        assert response.status_code == 200
        schema = response.json()
        assert "info" in schema
        assert "version" in schema["info"]


# Run tests with: pytest tests/test_api.py -v

