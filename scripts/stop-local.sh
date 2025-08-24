#!/bin/bash

# Personal AI Assistant - Local Development Shutdown Script

set -e

echo "🛑 Stopping Personal AI Assistant - Local Development Environment"
echo "================================================================="

# Navigate to the docker compose directory
cd "$(dirname "$0")/../docker/local"

# Stop and remove containers
echo "📦 Stopping services..."
docker compose down

# Optional: Remove volumes (uncomment if you want to reset all data)
# echo "🗑️  Removing volumes..."
# docker compose down -v

echo ""
echo "✅ All services stopped successfully!"
echo ""
echo "💡 To start again: ./start-local.sh"
echo "💡 To reset all data: docker compose down -v"
echo "💡 To view remaining containers: docker ps -a"