#!/bin/bash

# Script to check status of the metrics collection stack
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Claude Code Metrics Collection - Status"
echo "================================================"
echo ""

# Check if containers are running
echo "Docker Container Status:"
docker-compose ps

echo ""
echo "================================================"
echo ""

# Check connectivity to each service
echo "Service Health Checks:"
echo ""

# Check OpenTelemetry Collector
if docker ps --filter "name=claude-otel-collector" --filter "status=running" | grep -q claude-otel-collector; then
    # Check if Prometheus can scrape from OTEL collector
    if curl -s http://localhost:8889/metrics > /dev/null 2>&1; then
        echo "✅ OpenTelemetry Collector is healthy (ports 14317, 14318)"
    else
        echo "⚠️  OpenTelemetry Collector is running but metrics endpoint starting up..."
    fi
else
    echo "❌ OpenTelemetry Collector is not running"
fi

# Check Prometheus
if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo "✅ Prometheus is healthy (port 9090)"
else
    echo "❌ Prometheus is not responding"
fi

# Check Grafana
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ Grafana is healthy (port 3000)"
else
    echo "❌ Grafana is not responding"
fi

echo ""
echo "================================================"
echo ""

# Check if Claude Code is configured
if [ -f "$SCRIPT_DIR/claude-code-config.json" ]; then
    echo "Claude Code Configuration:"
    echo "  Config file: $SCRIPT_DIR/claude-code-config.json"
    echo ""
    echo "To use this configuration, set:"
    echo "  export CLAUDE_CODE_CONFIG=$SCRIPT_DIR/claude-code-config.json"
else
    echo "⚠️  Claude Code configuration file not found"
fi

echo ""
echo "================================================"
