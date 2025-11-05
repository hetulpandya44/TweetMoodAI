# Default Dockerfile - builds backend by default
# For separate builds, use Dockerfile.backend or Dockerfile.frontend
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/
COPY ui/ ./ui/
COPY models/ ./models/
COPY data/ ./data/

# Create necessary directories
RUN mkdir -p /app/models /app/data /app/logs

# Expose ports (8000 for API, 8501 for UI)
EXPOSE 8000 8501

# Default command runs FastAPI backend
# Override in docker-compose.yml for different services
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
