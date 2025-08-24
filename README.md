# Personal AI Config

Infrastructure configuration for secure deployment of the Personal AI Assistant system with Docker Compose, featuring local development setup and production-ready deployment with automatic HTTPS.

## 🚀 Quick Start (Local Development)

Get the entire Personal AI system running locally in under 5 minutes:

```bash
# Clone the repository (if not already done)
git clone <your-repo-url>
cd personal-ai-assistant/personal-ai-config

# Start all services
./scripts/start-local.sh

# Wait for startup, then access:
# 🌐 Open WebUI: http://localhost:3000
# 🚪 Gateway API: http://localhost:8080  
# 🧠 Memory Service: http://localhost:8001
```

That's it! The system will:
- Set up all databases (Neo4j, ChromaDB)
- Start all AI services (Memory, Gateway, Ollama)
- Launch Open WebUI frontend
- Generate API keys for 3 users
- Download the default AI model

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Open WebUI    │────│ Personal AI     │────│ Personal AI     │
│   (Frontend)    │    │ Gateway (API)   │    │ Memory Service  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │              ┌─────────────────┐              │
         │              │     Ollama      │              │
         │              │  (Local LLMs)   │              │
         │              └─────────────────┘              │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐    ┌─────────────────┐
                    │     Neo4j       │    │    ChromaDB     │
                    │ (Knowledge Graph)│    │ (Vector Store) │
                    └─────────────────┘    └─────────────────┘
```

### Services Included

| Service | Purpose | Port (Local) | Technology |
|---------|---------|--------------|------------|
| **Open WebUI** | User interface for AI chat | 3000 | React, Python |
| **Personal AI Gateway** | API orchestration & auth | 8080 | FastAPI, Python |
| **Personal AI Memory** | Memory & context management | 8001 | FastAPI, Python |
| **Ollama** | Local LLM inference | 11434 | Go, GGUF models |
| **ChromaDB** | Vector embeddings database | 8000 | Python, SQLite |
| **Neo4j** | Knowledge graph database | 7474/7687 | Java, Cypher |
| **Nginx** | Reverse proxy (local SSL) | 80/443 | C, HTTP server |

## 🔧 Configuration Options

### Local Development
- **Fast startup** with development defaults
- **Hot reloading** for code changes
- **Debug logging** enabled
- **No SSL** required (HTTP only)
- **Sample data** and test users

### Production Deployment
- **Automatic HTTPS** with Let's Encrypt
- **Security headers** and rate limiting
- **Resource limits** and health monitoring
- **Persistent data** with Docker volumes
- **Scalable architecture** ready for load

## 📋 Prerequisites

### Local Development
- Docker Desktop (4.0+)
- 8GB RAM minimum, 16GB recommended
- 20GB free disk space
- Internet connection (for downloading models)

### Production Deployment
- Docker and Docker Compose
- Domain name pointing to your server
- 16GB RAM minimum, 32GB recommended  
- 100GB+ SSD storage
- Ubuntu 20.04+ or similar Linux

## 🚀 Local Development Setup

### 1. Start All Services

```bash
# Navigate to config directory
cd personal-ai-config

# Start everything with one command
./scripts/start-local.sh
```

### 2. Access the System

Once started, you can access:

- **🌐 Open WebUI**: http://localhost:3000
  - Create account and login
  - Configure API: Base URL `http://localhost:8080/v1`
  - Use API key from startup output

- **🚪 Gateway API**: http://localhost:8080
  - OpenAI-compatible endpoints at `/v1/`
  - Health check at `/health`
  - Documentation at `/docs`

- **🧠 Memory Service**: http://localhost:8001
  - Memory operations API
  - Health check at `/health`
  - Admin interface at `/admin`

- **📊 Databases**:
  - Neo4j Browser: http://localhost:7474 (neo4j/personal_ai_password)
  - ChromaDB: http://localhost:8000

### 3. Default API Keys

The system generates 3 user API keys:
- `alice`: For primary user
- `bob`: For secondary user  
- `charlie`: For third user

Each user gets isolated memory and conversation history.

### 4. Management Commands

```bash
# View logs for all services
./scripts/logs.sh all -f

# View logs for specific service
./scripts/logs.sh gateway -f
./scripts/logs.sh memory --tail 100

# Stop all services
./scripts/stop-local.sh

# Restart a service
cd docker/local
docker compose restart personal-ai-gateway
```

## 🌐 Production Deployment

### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin

# Clone repository
git clone <your-repo-url>
cd personal-ai-assistant/personal-ai-config/docker/production
```

### 2. Environment Configuration

```bash
# Copy and edit environment file
cp .env.example .env
nano .env

# Required changes:
# - DOMAIN=your-domain.com
# - ADMIN_EMAIL=admin@your-domain.com  
# - Update all passwords and API keys
# - Add OpenAI API key (optional)
```

### 3. Generate Production API Keys

```bash
# Generate secure API keys
cd ../../../personal-ai-gateway
python generate_api_keys.py alice,bob,charlie

# Copy output to .env file as GATEWAY_API_KEYS
```

### 4. Deploy

```bash
# Return to production directory
cd ../../personal-ai-config/docker/production

# Start production stack
docker compose up -d

# Check service health
docker compose ps
docker compose logs -f caddy
```

### 5. Domain & SSL

Caddy automatically:
- Obtains SSL certificates from Let's Encrypt
- Redirects HTTP to HTTPS
- Handles certificate renewal
- Configures security headers

Your domain should resolve to:
- **Main site**: https://your-domain.com (Open WebUI)
- **API access**: https://api.your-domain.com (Gateway API)

### 6. Monitoring

```bash
# Check all services
docker compose ps

# View logs
docker compose logs -f [service-name]

# Monitor resources
docker stats

# Health checks
curl -f https://your-domain.com/health
curl -f https://api.your-domain.com/health
```

## 🔐 Security Features

### Local Development
- **User isolation** with API key authentication
- **CORS protection** for web browsers
- **Input validation** on all endpoints
- **Rate limiting** on API endpoints

### Production Deployment
- **Automatic HTTPS** with Let's Encrypt SSL
- **Security headers** (HSTS, CSP, etc.)
- **Network isolation** with Docker networks
- **Resource limits** to prevent abuse
- **Health monitoring** and automatic restarts
- **Firewall-ready** configuration

## 📊 Resource Requirements

### Local Development
- **CPU**: 4+ cores recommended
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 20GB free space
- **Network**: Broadband for model downloads

### Production Deployment
- **CPU**: 8+ cores for smooth operation
- **RAM**: 16GB minimum, 32GB+ recommended
- **Storage**: 100GB+ SSD storage
- **Network**: 100Mbps+ with unlimited data

## 🐳 Docker Images Used

| Service | Image | Size | Purpose |
|---------|-------|------|---------|
| ChromaDB | `chromadb/chroma:latest` | ~500MB | Vector database |
| Neo4j | `neo4j:5.20-community` | ~500MB | Graph database |
| Ollama | `ollama/ollama:latest` | ~1GB | LLM inference |
| Open WebUI | `ghcr.io/open-webui/open-webui:main` | ~800MB | Web interface |
| Caddy | `caddy:latest` | ~50MB | Reverse proxy |
| Nginx | `nginx:alpine` | ~25MB | Local proxy |

Total: ~3GB + your custom services + AI models

## 🔄 Updates & Maintenance

### Update All Services
```bash
# Local development
./scripts/stop-local.sh
docker compose pull
./scripts/start-local.sh

# Production
cd docker/production
docker compose pull
docker compose up -d
```

### Backup Data
```bash
# Local development
docker compose -f docker/local/docker-compose.yml exec neo4j \
  neo4j-admin backup --backup-dir=/data/backup

# Copy volumes
cp -r data/ backup/

# Production - similar but with volume mounts
```

### Monitor Logs
```bash
# Tail all service logs
docker compose logs -f

# Monitor specific service
docker compose logs -f personal-ai-gateway

# Check disk usage
docker system df
```

## 🔍 Troubleshooting

### Common Issues

**Services not starting:**
```bash
# Check Docker is running
docker info

# Check ports not in use
netstat -tulpn | grep :3000

# Check disk space
df -h
```

**Memory issues:**
```bash
# Check memory usage
free -h
docker stats

# Restart memory-hungry services
docker compose restart ollama
docker compose restart chromadb
```

**SSL issues (production):**
```bash
# Check Caddy logs
docker compose logs caddy

# Verify DNS
nslookup your-domain.com

# Check firewall
sudo ufw status
```

**Permission issues:**
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/

# Check Docker permissions
sudo usermod -aG docker $USER
```

### Debug Mode

```bash
# Enable debug logging
export LOG_LEVEL=DEBUG

# Restart with debug logs
docker compose down
docker compose up -d

# View detailed logs  
docker compose logs -f --details
```

## 📚 Additional Documentation

- [Personal AI Gateway](../personal-ai-gateway/README.md) - API and authentication
- [Personal AI Memory](../personal-ai-memory/README.md) - Memory system
- [Open WebUI Integration](../personal-ai-gateway/OPEN_WEBUI_INTEGRATION.md) - Frontend setup
- [Authentication Guide](../personal-ai-gateway/AUTHENTICATION_GUIDE.md) - User management

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Test** with local development setup
4. **Submit** pull request with clear description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Ready to experience the future of personal AI?** 🧠✨

Start with `./scripts/start-local.sh` and begin chatting with your memory-enhanced AI assistant in minutes!