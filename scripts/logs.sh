#!/bin/bash

# Personal AI Assistant - Log Viewer Script

cd "$(dirname "$0")/../docker/local"

echo "📋 Personal AI Assistant - Service Logs"
echo "======================================="
echo ""

if [ $# -eq 0 ]; then
    echo "Usage: $0 [service-name] [options]"
    echo ""
    echo "Available services:"
    echo "  • all                 - All services"
    echo "  • gateway            - Personal AI Gateway"
    echo "  • memory             - Personal AI Memory"
    echo "  • chromadb           - ChromaDB vector database"
    echo "  • neo4j              - Neo4j graph database"
    echo "  • ollama             - Ollama LLM service"
    echo "  • open-webui         - Open WebUI frontend"
    echo "  • nginx              - Nginx reverse proxy"
    echo ""
    echo "Options:"
    echo "  -f, --follow         Follow log output"
    echo "  --tail N             Number of lines to show from end"
    echo ""
    echo "Examples:"
    echo "  $0 gateway -f        # Follow gateway logs"
    echo "  $0 all --tail 100    # Last 100 lines from all services"
    echo "  $0 memory            # Show memory service logs"
    exit 1
fi

SERVICE=$1
shift

case $SERVICE in
    "all")
        echo "📊 Showing logs for all services..."
        docker compose logs "$@"
        ;;
    "gateway"|"personal-ai-gateway")
        echo "🚪 Showing Gateway logs..."
        docker compose logs personal-ai-gateway "$@"
        ;;
    "memory"|"personal-ai-memory")
        echo "🧠 Showing Memory service logs..."
        docker compose logs personal-ai-memory "$@"
        ;;
    "chromadb"|"chroma")
        echo "🗃️ Showing ChromaDB logs..."
        docker compose logs chromadb "$@"
        ;;
    "neo4j"|"graph")
        echo "🕸️ Showing Neo4j logs..."
        docker compose logs neo4j "$@"
        ;;
    "ollama"|"llm")
        echo "🤖 Showing Ollama logs..."
        docker compose logs ollama "$@"
        ;;
    "webui"|"open-webui"|"ui")
        echo "🌐 Showing Open WebUI logs..."
        docker compose logs open-webui "$@"
        ;;
    "nginx"|"proxy")
        echo "🔀 Showing Nginx logs..."
        docker compose logs nginx "$@"
        ;;
    *)
        echo "❌ Unknown service: $SERVICE"
        echo "Run without arguments to see available services"
        exit 1
        ;;
esac