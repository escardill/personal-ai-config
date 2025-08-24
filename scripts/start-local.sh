#!/bin/bash

# Personal AI Assistant - Local Development Startup Script

set -e

echo "🚀 Starting Personal AI Assistant - Local Development Environment"
echo "=================================================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Navigate to the docker compose directory
cd "$(dirname "$0")/../docker/local"

# Create necessary directories
echo "📁 Creating data directories..."
mkdir -p ../../data/{chromadb,neo4j/{data,logs,conf},ollama,open-webui,logs/{nginx,memory,gateway}}

# Generate API keys if they don't exist
if [ ! -f "../../configs/env/.api_keys_generated" ]; then
    echo "🔑 Generating API keys for local development..."
    cd ../../../personal-ai-gateway
    python generate_api_keys.py alice,bob,charlie > ../personal-ai-config/configs/env/.api_keys_generated
    echo "✅ API keys generated and saved"
    cd ../../personal-ai-config/docker/local
fi

# Pull latest images
echo "📦 Pulling latest Docker images..."
docker compose pull

# Start the services
echo "🚀 Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to be ready..."
echo "   This may take a few minutes on first run..."

# Function to check service health
check_service() {
    local service_name=$1
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker compose ps $service_name | grep -q "healthy"; then
            echo "   ✅ $service_name is ready"
            return 0
        fi
        echo "   ⏳ Waiting for $service_name... (attempt $attempt/$max_attempts)"
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo "   ❌ $service_name failed to become ready"
    return 1
}

# Check each service
check_service "chromadb"
check_service "neo4j"
check_service "personal-ai-memory"
check_service "personal-ai-gateway"
check_service "open-webui"

# Download Ollama model if needed
echo "🤖 Setting up Ollama model..."
docker compose exec ollama ollama pull llama3.1:8b || echo "⚠️  Ollama model download failed - you can do this manually later"

echo ""
echo "🎉 Personal AI Assistant is ready!"
echo "================================="
echo ""
echo "🌐 Access URLs:"
echo "   • Open WebUI:           http://localhost:3000"
echo "   • Gateway API:          http://localhost:8080"
echo "   • Memory Service:       http://localhost:8001"
echo "   • Neo4j Browser:        http://localhost:7474"
echo "   • ChromaDB:             http://localhost:8000"
echo ""
echo "🔑 Default User API Keys:"
if [ -f "../../configs/env/.api_keys_generated" ]; then
    grep "User.*API Key:" ../../configs/env/.api_keys_generated
fi
echo ""
echo "📚 Documentation:"
echo "   • Gateway: ../../../personal-ai-gateway/README.md"
echo "   • Memory:  ../../../personal-ai-memory/README.md"
echo ""
echo "🛠️  Management Commands:"
echo "   • View logs:     docker compose logs -f [service-name]"
echo "   • Stop all:      ./stop-local.sh"
echo "   • Restart:       docker compose restart [service-name]"
echo "   • Update:        docker compose pull && docker compose up -d"
echo ""
echo "Happy chatting! 🤖💬"