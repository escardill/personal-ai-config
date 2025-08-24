# Personal AI Assistant - Fly.io Deployment Guide

This guide explains how to deploy your Personal AI Assistant to Fly.io with **autostart/autostop** capabilities for cost optimization.

## 🚀 What This Deploys

Your entire AI stack in **one Fly app**:
- **Open WebUI** - User interface (port 3000)
- **Personal AI Gateway** - API service (port 8080) 
- **Personal AI Memory** - Memory system (port 8001)
- **ChromaDB** - Vector database (port 8000)
- **Neo4j** - Graph database (ports 7474, 7687)
- **Ollama** - LLM inference (port 11434)

## 🎯 Key Benefits

- ✅ **Cost optimization** - Only pay when using
- ✅ **Auto-start** - Wakes up on first request
- ✅ **Auto-stop** - Suspends after 2-5 minutes idle
- ✅ **Persistent data** - All databases survive stops/starts
- ✅ **Single deployment** - One command to deploy everything

## 📋 Prerequisites

1. **Install Fly CLI**:
   ```bash
   # macOS
   brew install flyctl
   
   # Linux
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly**:
   ```bash
   fly auth login
   ```

3. **Choose a region** (update `fly.toml`):
   ```bash
   # List available regions
   fly platform regions
   
   # Recommended: mad (Madrid), ams (Amsterdam), fra (Frankfurt)
   ```

## 🚀 Quick Deployment

### 1. Navigate to Fly Directory
```bash
cd personal-ai-config/docker/production/fly
```

### 2. Create Fly App
```bash
# Create app (don't deploy yet)
fly launch --no-deploy --name your-ai-assistant --region mad
```

### 3. Create Persistent Volumes
```bash
# Create volumes for your databases
fly volumes create chromadb_data --region mad --size 20
fly volumes create neo4j_data --region mad --size 20
fly volumes create neo4j_logs --region mad --size 10
fly volumes create ollama_data --region mad --size 50
fly volumes create openwebui_data --region mad --size 10
fly volumes create logs_data --region mad --size 5
```

### 4. Set Environment Variables
```bash
# Set your API keys and configuration
fly secrets set \
  API_KEYS="alice:your_key_here,bob:your_key_here" \
  NEO4J_PASSWORD="your_secure_password" \
  MEMORY_API_SECRET_KEY="your_memory_secret"
```

### 5. Deploy
```bash
fly deploy
```

## 🔧 Configuration

### Auto-Start/Stop Settings

In `fly.toml`:
```toml
[http_service]
  auto_start_machines = true      # Wake up on request
  auto_stop_machines = "suspend" # Suspend when idle (faster wake-up)
  min_machines_running = 0       # No machines running when idle
```

**Timing**:
- **Suspend mode**: ~5-10 second wake-up
- **Stop mode**: ~15-30 second wake-up (cheaper)

### Resource Limits

```toml
[[vm]]
  cpu_kind = "shared"
  cpus = 4
  memory = "8GB"
```

**Adjust based on your needs**:
- **Light usage**: 2 CPU, 4GB RAM
- **Heavy usage**: 8 CPU, 16GB RAM
- **GPU support**: Add GPU configuration

## 🌐 Access Your App

### After Deployment

1. **Get your app URL**:
   ```bash
   fly status
   ```

2. **Access Open WebUI**:
   ```
   https://your-ai-assistant.fly.dev
   ```

3. **API endpoints**:
   ```
   https://your-ai-assistant.fly.dev/v1/chat/completions
   https://your-ai-assistant.fly.dev/health
   ```

### Custom Domain

```bash
# Add your domain
fly certs add ai.yourdomain.com

# Create CNAME record pointing to your Fly app
# ai.yourdomain.com → your-ai-assistant.fly.dev
```

## 💰 Cost Optimization

### Auto-Stop Benefits

- **Idle time**: ~$0.50-1.00/month (suspend mode)
- **Active use**: ~$20-50/month (depending on usage)
- **Savings**: 80-90% cost reduction when not in use

### Volume Costs

- **ChromaDB**: $2.50/month (20GB)
- **Neo4j**: $2.50/month (20GB)
- **Ollama**: $6.25/month (50GB)
- **Total storage**: ~$11.25/month

## 🔍 Monitoring

### Check App Status
```bash
# View app status
fly status

# Check machine status
fly machines list

# View logs
fly logs
```

### Health Checks
```bash
# Test health endpoint
curl https://your-ai-assistant.fly.dev/health

# Test Open WebUI
curl https://your-ai-assistant.fly.dev
```

## 🛠️ Troubleshooting

### Common Issues

**App won't start**:
```bash
# Check logs
fly logs

# Restart app
fly apps restart your-ai-assistant
```

**Volume mount issues**:
```bash
# Check volume status
fly volumes list

# Recreate if needed
fly volumes destroy chromadb_data
fly volumes create chromadb_data --region mad --size 20
```

**Memory/CPU issues**:
```bash
# Scale up resources
fly scale memory 16384
fly scale cpu 8
```

### Debug Mode

```bash
# SSH into your machine
fly ssh console

# Check running processes
ps aux

# Check disk usage
df -h

# Check service logs
tail -f /data/logs/*.log
```

## 🔄 Updates

### Deploy Updates
```bash
# Pull latest code
git pull

# Deploy to Fly
fly deploy
```

### Rollback
```bash
# List deployments
fly deployments list

# Rollback to previous version
fly deploy --image-label v1
```

## 📚 Next Steps

1. **Test your deployment** - Visit your app URL
2. **Configure authentication** - Set up API keys
3. **Monitor costs** - Check Fly dashboard
4. **Set up monitoring** - Add health checks
5. **Backup strategy** - Plan for data persistence

## 🆘 Support

- **Fly Documentation**: https://fly.io/docs/
- **Fly Community**: https://community.fly.io/
- **Personal AI Issues**: Check your repository

---

**Happy deploying! 🚀✨**

Your AI assistant will now wake up when you need it and sleep when you don't, saving you money while keeping your data safe.
