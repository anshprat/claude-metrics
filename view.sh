#!/bin/bash

# Script to open the Grafana dashboard
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Grafana is running
if ! docker ps | grep -q claude-grafana; then
    echo "❌ Grafana is not running!"
    echo "Please start the stack first: ./start.sh"
    exit 1
fi

GRAFANA_URL="http://localhost:3000/d/claude-code-metrics/claude-code-token-usage-costs"

echo "Opening Claude Code Metrics Dashboard..."
echo "URL: $GRAFANA_URL"
echo ""
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""

# Try to open in default browser
if command -v open &> /dev/null; then
    # macOS
    open "$GRAFANA_URL"
elif command -v xdg-open &> /dev/null; then
    # Linux
    xdg-open "$GRAFANA_URL"
elif command -v wslview &> /dev/null; then
    # WSL
    wslview "$GRAFANA_URL"
else
    echo "Please open the following URL in your browser:"
    echo "$GRAFANA_URL"
fi
