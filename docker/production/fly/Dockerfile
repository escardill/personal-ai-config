# Personal AI Assistant - Multi-Service Production Dockerfile for Fly.io
# This runs all services in one container for cost-effective deployment

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    software-properties-common \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY personal-ai-gateway/requirements.txt ./gateway-requirements.txt
COPY personal-ai-memory/requirements.txt ./memory-requirements.txt

RUN pip install --no-cache-dir -r gateway-requirements.txt
RUN pip install --no-cache-dir -r memory-requirements.txt

# Install Ollama
RUN curl -fsSL https://ollama.ai/install.sh | sh

# Create data directories
RUN mkdir -p /data/{chromadb,neo4j/{data,logs},ollama,open-webui,logs}

# Copy application code
COPY personal-ai-gateway/src/ ./personal-ai-gateway/src/
COPY personal-ai-memory/src/ ./personal-ai-memory/src/

# Copy Open WebUI (we'll use the official image but extract what we need)
COPY --from=ghcr.io/open-webui/open-webui:main /app/backend /app/open-webui

# Copy startup scripts
COPY docker/production/fly/start-services.sh /start-services.sh
RUN chmod +x /start-services.sh

# Expose ports
EXPOSE 8000 8001 8080 11434 7474 7687

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start all services
CMD ["/start-services.sh"]
