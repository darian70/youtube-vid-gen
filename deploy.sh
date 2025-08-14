#!/bin/bash
set -e

echo "🚀 Deploying Automated YouTube Video Generation System..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p n8n_data piper_data workspace

# Download voice models
echo "🎵 Setting up TTS voices..."
if [ ! -f "piper_data/en_US-lessac-medium.onnx" ]; then
    ./setup-voices.sh
else
    echo "✅ Voice models already exist"
fi

# Build and start services
echo "🐳 Building and starting Docker services..."
docker-compose down -v 2>/dev/null || true
docker-compose build --no-cache
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if n8n is accessible
echo "🔍 Checking n8n accessibility..."
for i in {1..30}; do
    if curl -s http://localhost:5678 > /dev/null; then
        echo "✅ n8n is accessible at http://localhost:5678"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ n8n is not accessible after 30 attempts"
        exit 1
    fi
    echo "Waiting for n8n... ($i/30)"
    sleep 2
done

# Check if Piper TTS is accessible
echo "🔍 Checking Piper TTS accessibility..."
for i in {1..15}; do
    if curl -s http://localhost:8080/api/voices > /dev/null; then
        echo "✅ Piper TTS is accessible at http://localhost:8080"
        break
    fi
    if [ $i -eq 15 ]; then
        echo "❌ Piper TTS is not accessible after 15 attempts"
        exit 1
    fi
    echo "Waiting for Piper TTS... ($i/15)"
    sleep 2
done

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Access n8n at: http://localhost:5678"
echo "   Username: admin"
echo "   Password: admin12345"
echo ""
echo "2. Configure YouTube OAuth2 credentials:"
echo "   - Go to Settings > Credentials"
echo "   - Add 'YouTube OAuth2 API' credential"
echo "   - Use your Google Cloud Console OAuth2 credentials"
echo ""
echo "3. Import workflows:"
echo "   - Import workflows/daily.json"
echo "   - Import workflows/on-demand.json"
echo "   - Activate both workflows"
echo ""
echo "4. Test on-demand video creation:"
echo "   curl -X POST http://localhost:5678/webhook/create-video \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"term\": \"serendipity\"}'"
echo ""
echo "🔧 Troubleshooting:"
echo "   docker-compose logs -f    # View all logs"
echo "   docker-compose restart    # Restart services"
echo "   docker-compose down -v    # Reset everything"
echo ""
