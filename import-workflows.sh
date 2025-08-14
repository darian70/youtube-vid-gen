#!/bin/bash
set -e

echo "📥 Importing n8n workflows..."

# Check if n8n is running
if ! curl -s http://localhost:5678 > /dev/null; then
    echo "❌ n8n is not accessible. Please run ./deploy.sh first."
    exit 1
fi

# Function to import workflow
import_workflow() {
    local file=$1
    local name=$2
    
    echo "Importing $name..."
    
    # Read workflow JSON
    workflow_json=$(cat "$file")
    
    # Import via n8n API (using basic auth)
    response=$(curl -s -X POST \
        -u "admin:admin12345" \
        -H "Content-Type: application/json" \
        -d "$workflow_json" \
        "http://localhost:5678/rest/workflows")
    
    if echo "$response" | grep -q '"id"'; then
        echo "✅ Successfully imported $name"
    else
        echo "❌ Failed to import $name"
        echo "Response: $response"
    fi
}

# Import workflows
if [ -f "workflows/daily.json" ]; then
    import_workflow "workflows/daily.json" "Daily Etymology Workflow"
else
    echo "❌ workflows/daily.json not found"
fi

if [ -f "workflows/on-demand.json" ]; then
    import_workflow "workflows/on-demand.json" "On-Demand Etymology Workflow"
else
    echo "❌ workflows/on-demand.json not found"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Go to http://localhost:5678"
echo "2. Login with admin/admin12345"
echo "3. Configure YouTube OAuth2 credentials in Settings > Credentials"
echo "4. Activate both imported workflows"
echo "5. Test the on-demand workflow with:"
echo "   curl -X POST http://localhost:5678/webhook/create-video -H 'Content-Type: application/json' -d '{\"term\": \"test\"}'"
