#!/bin/bash

# Personal AI Assistant - Multi-Service Startup Script for Fly.io
# This script starts all services in the correct order

set -e

echo "🚀 Starting Personal AI Assistant services..."

# Create data directories if they don't exist
mkdir -p /data/{chromadb,neo4j/{data,logs},ollama,open-webui,logs}

# Start ChromaDB
echo "🗃️  Starting ChromaDB..."
cd /app
python -m chromadb.app --host 0.0.0.0 --port 8000 --path /data/chromadb &
CHROMADB_PID=$!

# Start Neo4j
echo "🕸️  Starting Neo4j..."
cd /app
neo4j start &
NEO4J_PID=$!

# Wait for databases to be ready
echo "⏳ Waiting for databases to be ready..."
sleep 30

# Start Personal AI Memory service
echo "🧠 Starting Personal AI Memory service..."
cd /app
python -m uvicorn personal_ai_memory.api.app:app --host 0.0.0.0 --port 8001 &
MEMORY_PID=$!

# Start Ollama
echo "🤖 Starting Ollama..."
ollama serve &
OLLAMA_PID=$!

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 20

# Start Open WebUI
echo "🌐 Starting Open WebUI..."
cd /app/open-webui
python -m uvicorn openwebui.main:app --host 0.0.0.0 --port 3000 &
WEBUI_PID=$!

# Wait for all services
echo "⏳ Waiting for all services to be ready..."
sleep 10

# Start Personal AI Gateway (main service)
echo "🚪 Starting Personal AI Gateway..."
cd /app
python -m uvicorn personal_ai_gateway.api.app:app --host 0.0.0.0 --port 8080 &
GATEWAY_PID=$!

echo "✅ All services started!"
echo "   • ChromaDB: http://localhost:8000"
echo "   • Neo4j: http://localhost:7474"
echo "   • Memory Service: http://localhost:8001"
echo "   • Ollama: http://localhost:11434"
echo "   • Open WebUI: http://localhost:3000"
echo "   • Gateway API: http://localhost:8080"

# Function to handle shutdown
cleanup() {
    echo "🛑 Shutting down services..."
    kill $CHROMADB_PID $NEO4J_PID $MEMORY_PID $OLLAMA_PID $WEBUI_PID $GATEWAY_PID 2>/dev/null || true
    wait
    echo "✅ All services stopped"
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Wait for the main gateway process
wait $GATEWAY_PID
