#!/bin/bash

# Personal AI Assistant - Setup Verification Script

set -e

echo "🧪 Personal AI Assistant - Setup Verification"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_check() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "  Testing $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Navigate to docker compose directory
cd "$(dirname "$0")/../docker/local"

echo -e "${BLUE}🔧 Environment Tests${NC}"
echo "-------------------"

# Test Docker
test_check "Docker installation" "docker --version"
test_check "Docker daemon running" "docker info"
test_check "Docker Compose available" "docker compose --version"

echo ""
echo -e "${BLUE}📁 File Structure Tests${NC}"
echo "----------------------"

# Test file structure
test_check "Docker Compose file exists" "[ -f docker-compose.yml ]"
test_check "Environment configs exist" "[ -d ../../configs/env ]"
test_check "Scripts directory exists" "[ -d ../../scripts ]"
test_check "Data directories created" "mkdir -p ../../data/{chromadb,neo4j,ollama,open-webui,logs} && [ -d ../../data ]"

echo ""
echo -e "${BLUE}🐳 Docker Services Tests${NC}"
echo "------------------------"

# Check if services are running
if docker compose ps | grep -q "Up"; then
    echo "  Services appear to be running. Testing endpoints..."
    
    # Test service endpoints
    test_check "ChromaDB health" "curl -f http://localhost:8000/api/v1/heartbeat"
    test_check "Neo4j accessibility" "curl -f http://localhost:7474"
    test_check "Ollama service" "curl -f http://localhost:11434/api/tags"
    
    if curl -f http://localhost:8001/health > /dev/null 2>&1; then
        test_check "Personal AI Memory service" "curl -f http://localhost:8001/health"
    else
        echo "  ⏳ Memory service not ready - this is normal on first startup"
    fi
    
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        test_check "Personal AI Gateway service" "curl -f http://localhost:8080/health"
    else
        echo "  ⏳ Gateway service not ready - this is normal on first startup"
    fi
    
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        test_check "Open WebUI accessibility" "curl -f http://localhost:3000"
    else
        echo "  ⏳ Open WebUI not ready - this is normal on first startup"
    fi
    
else
    echo "  ℹ️  Services not running. Run './scripts/start-local.sh' to start them."
    echo "  Skipping endpoint tests..."
fi

echo ""
echo -e "${BLUE}🔑 API Keys Test${NC}"
echo "---------------"

# Test API key generation
if [ -f "../../../personal-ai-gateway/generate_api_keys.py" ]; then
    test_check "API key generator exists" "[ -f ../../../personal-ai-gateway/generate_api_keys.py ]"
    
    # Test API key generation
    if cd ../../../personal-ai-gateway && python generate_api_keys.py alice > /tmp/test_keys.txt 2>&1; then
        test_check "API key generation works" "grep -q 'pai_' /tmp/test_keys.txt"
        rm -f /tmp/test_keys.txt
        cd - > /dev/null
    else
        echo -e "  ${YELLOW}⚠️  API key generation failed - check Python dependencies${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        cd - > /dev/null
    fi
else
    echo -e "  ${YELLOW}⚠️  API key generator not found${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""
echo -e "${BLUE}📋 Summary${NC}"
echo "---------"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All tests passed! Your setup looks good.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Run './scripts/start-local.sh' to start all services"
    echo "2. Wait 2-3 minutes for services to initialize"
    echo "3. Access Open WebUI at http://localhost:3000"
    echo "4. Configure API with base URL: http://localhost:8080/v1"
    echo ""
else
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed. Please check the issues above.${NC}"
    echo ""
    echo "Common solutions:"
    echo "• Make sure Docker Desktop is running"
    echo "• Check if ports 3000, 8000, 8001, 8080 are available"
    echo "• Install Python dependencies in gateway directory"
    echo "• Ensure sufficient disk space (20GB+) and memory (8GB+)"
    echo ""
fi

echo -e "${BLUE}📚 Helpful Resources${NC}"
echo "--------------------"
echo "• Documentation: ../README.md"
echo "• Start services: ./start-local.sh"
echo "• View logs: ./logs.sh all -f"
echo "• Stop services: ./stop-local.sh"
echo ""