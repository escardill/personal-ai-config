#!/bin/bash

# Personal AI Assistant - Fly.io Deployment Script

set -e

echo "🚀 Deploying Personal AI Assistant to Fly.io"
echo "=============================================="

# Check if flyctl is installed
if ! command -v flyctl &> /dev/null; then
    echo "❌ flyctl is not installed. Please install it first:"
    echo "   macOS: brew install flyctl"
    echo "   Linux: curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if user is logged in
if ! fly auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly. Please run: fly auth login"
    exit 1
fi

# Get app name from fly.toml or prompt user
APP_NAME=$(grep '^app = ' fly.toml | cut -d'"' -f2 2>/dev/null || echo "")

if [ -z "$APP_NAME" ]; then
    echo "📝 Enter your Fly app name:"
    read -p "App name: " APP_NAME
fi

echo "📱 Deploying to app: $APP_NAME"

# Check if app exists
if ! fly apps list | grep -q "$APP_NAME"; then
    echo "❌ App '$APP_NAME' does not exist. Please create it first:"
    echo "   fly launch --no-deploy --name $APP_NAME --region mad"
    exit 1
fi

# Check if volumes exist
echo "🔍 Checking volumes..."
VOLUMES=("chromadb_data" "neo4j_data" "neo4j_logs" "ollama_data" "openwebui_data" "logs_data")

for volume in "${VOLUMES[@]}"; do
    if ! fly volumes list | grep -q "$volume"; then
        echo "⚠️  Volume '$volume' not found. Creating it..."
        fly volumes create "$volume" --region mad --size 20
    else
        echo "✅ Volume '$volume' exists"
    fi
done

# Deploy the app
echo "🚀 Deploying app..."
fly deploy

echo ""
echo "🎉 Deployment complete!"
echo "======================"
echo ""
echo "🌐 Your app is available at:"
echo "   https://$APP_NAME.fly.dev"
echo ""
echo "📊 Check status:"
echo "   fly status"
echo ""
echo "📝 View logs:"
echo "   fly logs"
echo ""
echo "🔧 SSH into machine:"
echo "   fly ssh console"
echo ""
echo "Happy chatting! 🤖💬"
