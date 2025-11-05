#!/bin/bash
# Test script to verify Docker services are working correctly
# This can be run after docker-compose up

echo "========================================"
echo "Testing Docker Services"
echo "========================================"

# Wait for services to be ready
echo ""
echo "[*] Waiting for services to start (30 seconds)..."
sleep 30

# Test Backend Health
echo ""
echo "[*] Testing Backend Health Check..."
BACKEND_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/healthz)
if [ "$BACKEND_HEALTH" = "200" ]; then
    echo "[OK] Backend is healthy (HTTP $BACKEND_HEALTH)"
else
    echo "[ERROR] Backend health check failed (HTTP $BACKEND_HEALTH)"
fi

# Test Backend API
echo ""
echo "[*] Testing Backend API endpoint..."
BACKEND_API=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/)
if [ "$BACKEND_API" = "200" ]; then
    echo "[OK] Backend API is responding (HTTP $BACKEND_API)"
else
    echo "[ERROR] Backend API not responding (HTTP $BACKEND_API)"
fi

# Test Frontend
echo ""
echo "[*] Testing Frontend..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8501/)
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "[OK] Frontend is accessible (HTTP $FRONTEND_STATUS)"
else
    echo "[ERROR] Frontend not accessible (HTTP $FRONTEND_STATUS)"
fi

# Test API prediction endpoint
echo ""
echo "[*] Testing Sentiment Analysis API..."
PREDICT_RESPONSE=$(curl -s -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"tweet_text": "This is a test tweet!"}' | head -c 100)
if [ -n "$PREDICT_RESPONSE" ]; then
    echo "[OK] Prediction endpoint is working"
    echo "Response preview: $PREDICT_RESPONSE"
else
    echo "[ERROR] Prediction endpoint failed"
fi

echo ""
echo "========================================"
echo "Service Status:"
echo "========================================"
docker-compose ps

echo ""
echo "[OK] Testing complete!"
echo ""
echo "Access services at:"
echo "  Backend:  http://localhost:8000"
echo "  Frontend: http://localhost:8501"
echo "  API Docs: http://localhost:8000/docs"

