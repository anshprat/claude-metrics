#!/bin/bash

# Script to stop the Claude Code metrics collection stack
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Stopping Claude Code Metrics Collection Stack..."
echo "================================================"

# Stop Docker containers
docker-compose down

echo ""
echo "✅ Stack stopped successfully!"
echo ""
echo "Note: Data is preserved in Docker volumes."
echo "To completely remove all data, run: docker-compose down -v"
echo "================================================"
