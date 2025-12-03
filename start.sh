#!/bin/bash

# Script to start the Claude Code metrics collection stack
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Starting Claude Code Metrics Collection Stack..."
echo "================================================"

# Start Docker containers
echo "Starting Docker containers..."
docker-compose up -d

echo ""
echo "Waiting for services to be ready..."
sleep 5

# Check if services are running
echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "================================================"
echo "✅ Stack started successfully!"
echo ""
echo "Services available at:"
echo "  - Grafana:             http://localhost:3000"
echo "    (username: admin, password: admin)"
echo "  - Prometheus:          http://localhost:9090"
echo "  - OpenTelemetry:       http://localhost:4318 (HTTP)"
echo "                         http://localhost:4317 (gRPC)"
echo ""
echo "To configure Claude Code to send metrics:"
echo "  1. Set the CLAUDE_CODE_CONFIG environment variable:"
echo "     export CLAUDE_CODE_CONFIG=$SCRIPT_DIR/claude-code-config.json"
echo ""
echo "  2. Or manually configure Claude Code settings to point to:"
echo "     Endpoint: http://localhost:4318"
echo "     Protocol: http"
echo ""
echo "To view logs: ./logs.sh"
echo "To stop:      ./stop.sh"
echo "To view dashboard: ./view.sh"
echo "================================================"
