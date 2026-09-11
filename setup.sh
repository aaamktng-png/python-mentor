#!/bin/bash

# Python Mentor Setup Script
# This script sets up and runs the entire application

set -e  # Exit on any error

echo "🚀 Python Mentor Setup & Launch"
echo "================================="
echo ""

# Step 1: Check prerequisites
echo "✓ Step 1: Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install it from https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Step 2: Setup environment files
echo "✓ Step 2: Setting up environment variables..."

if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    echo "✅ Created backend/.env"
else
    echo "ℹ️  backend/.env already exists, skipping"
fi

if [ ! -f "frontend/.env" ]; then
    cp frontend/.env.example frontend/.env
    echo "✅ Created frontend/.env"
else
    echo "ℹ️  frontend/.env already exists, skipping"
fi

echo ""

# Step 3: Start Docker Compose
echo "✓ Step 3: Starting Docker containers..."
echo "This may take a few minutes on first run..."
echo ""

docker-compose up -d

# Step 4: Wait for services to be healthy
echo ""
echo "✓ Step 4: Waiting for services to start (this may take 30-60 seconds)..."

# Function to check if service is healthy
check_service() {
    local port=$1
    local name=$2
    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:$port/health &> /dev/null || curl -s http://localhost:$port &> /dev/null; then
            echo "✅ $name is running at http://localhost:$port"
            return 0
        fi
        attempt=$((attempt + 1))
        echo "  Waiting for $name... ($attempt/$max_attempts)"
        sleep 2
    done

    echo "⚠️  $name might not be ready yet, but it may still be starting in background"
    return 0
}

# Check PostgreSQL
echo ""
echo "Checking PostgreSQL..."
if docker-compose exec -T postgres pg_isready -U pythonmentor &> /dev/null; then
    echo "✅ PostgreSQL is running"
else
    echo "⚠️  PostgreSQL is starting, please wait..."
fi

# Check Backend
echo ""
echo "Checking Backend API..."
check_service 5000 "Backend API"

# Check Frontend
echo ""
echo "Checking Frontend..."
check_service 3000 "Frontend"

echo ""
echo "================================="
echo "✅ Setup Complete!"
echo "================================="
echo ""
echo "📋 Your application is ready!"
echo ""
echo "🌐 Access the application:"
echo "   Frontend:  http://localhost:3000"
echo "   Backend:   http://localhost:5000"
echo "   API Docs:  http://localhost:5000/api/v1/"
echo ""
echo "🧪 Quick tests:"
echo "   Backend health:  curl http://localhost:5000/health"
echo "   API info:        curl http://localhost:5000/api/v1/"
echo ""
echo "🛑 To stop the application:"
echo "   docker-compose down"
echo ""
echo "📊 View logs:"
echo "   docker-compose logs -f backend      # Backend logs"
echo "   docker-compose logs -f frontend     # Frontend logs"
echo "   docker-compose logs -f postgres     # Database logs"
echo ""
echo "🔄 Restart services:"
echo "   docker-compose restart"
echo ""
