#!/bin/bash
set -e

echo "🧪 Testing Automated YouTube Video Generation System..."

# Check if services are running
echo "🔍 Checking service status..."

if ! curl -s http://localhost:5678 > /dev/null; then
    echo "❌ n8n is not accessible at http://localhost:5678"
    echo "Run ./deploy.sh to start the system"
    exit 1
fi
echo "✅ n8n is running"

if ! curl -s http://localhost:8080/api/voices > /dev/null; then
    echo "❌ Piper TTS is not accessible at http://localhost:8080"
    exit 1
fi
echo "✅ Piper TTS is running"

# Test voice availability
echo "🎵 Testing TTS voices..."
voices=$(curl -s http://localhost:8080/api/voices)
if echo "$voices" | grep -q "en_US-lessac-medium.onnx"; then
    echo "✅ Primary voice (en_US-lessac-medium.onnx) is available"
else
    echo "⚠️  Primary voice not found, checking for backup..."
    if echo "$voices" | grep -q "en_US-amy-low.onnx"; then
        echo "✅ Backup voice (en_US-amy-low.onnx) is available"
    else
        echo "❌ No suitable voices found. Run ./setup-voices.sh"
        exit 1
    fi
fi

# Test TTS generation
echo "🗣️  Testing TTS generation..."
tts_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"text": "Testing TTS functionality", "voice": "en_US-lessac-medium.onnx"}' \
    http://localhost:8080/api/tts \
    --output /tmp/test_audio.wav \
    --write-out "%{http_code}")

if [ "$tts_response" = "200" ] && [ -f "/tmp/test_audio.wav" ]; then
    echo "✅ TTS generation successful"
    rm -f /tmp/test_audio.wav
else
    echo "❌ TTS generation failed (HTTP: $tts_response)"
    exit 1
fi

# Test n8n API access
echo "🔧 Testing n8n API access..."
n8n_status=$(curl -s -u "admin:admin12345" \
    "http://localhost:5678/rest/workflows" \
    --write-out "%{http_code}" \
    --output /tmp/workflows.json)

if [ "$n8n_status" = "200" ]; then
    echo "✅ n8n API access successful"
    workflow_count=$(cat /tmp/workflows.json | grep -o '"id"' | wc -l)
    echo "📊 Found $workflow_count workflows"
    rm -f /tmp/workflows.json
else
    echo "❌ n8n API access failed (HTTP: $n8n_status)"
    exit 1
fi

# Test webhook endpoint (if on-demand workflow is active)
echo "🌐 Testing webhook endpoint..."
webhook_response=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"term": "test"}' \
    http://localhost:5678/webhook/create-video \
    --write-out "%{http_code}" \
    --output /tmp/webhook_response.txt)

if [ "$webhook_response" = "200" ] || [ "$webhook_response" = "404" ]; then
    if [ "$webhook_response" = "200" ]; then
        echo "✅ Webhook endpoint is active and responding"
        echo "📝 Response: $(cat /tmp/webhook_response.txt)"
    else
        echo "⚠️  Webhook endpoint not found (workflow may not be active)"
        echo "   Import and activate workflows/on-demand.json in n8n UI"
    fi
    rm -f /tmp/webhook_response.txt
else
    echo "❌ Webhook test failed (HTTP: $webhook_response)"
    rm -f /tmp/webhook_response.txt
fi

# Check directory structure
echo "📁 Checking directory structure..."
for dir in "n8n_data" "piper_data" "workspace"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/ exists"
    else
        echo "❌ $dir/ missing"
    fi
done

# Check voice files
echo "🎤 Checking voice files..."
voice_count=$(find piper_data -name "*.onnx" 2>/dev/null | wc -l)
if [ "$voice_count" -gt 0 ]; then
    echo "✅ Found $voice_count voice model(s)"
    find piper_data -name "*.onnx" -exec basename {} \;
else
    echo "❌ No voice models found. Run ./setup-voices.sh"
fi

echo ""
echo "🎉 System test completed!"
echo ""
echo "📋 Summary:"
echo "- n8n Web UI: http://localhost:5678 (admin/admin12345)"
echo "- Piper TTS API: http://localhost:8080"
echo "- Webhook endpoint: http://localhost:5678/webhook/create-video"
echo ""
echo "🚀 To create a test video:"
echo "curl -X POST http://localhost:5678/webhook/create-video \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"term\": \"serendipity\"}'"
