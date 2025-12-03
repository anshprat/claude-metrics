#!/bin/bash

# Start Claude Code with telemetry using gRPC protocol
# Usage: ./start-claude-grpc.sh

echo "Starting Claude Code with telemetry (gRPC protocol)..."
echo ""
echo "Configuration:"
echo "  - OTLP Endpoint: http://localhost:14317 (gRPC)"
echo "  - Export Interval: 10 seconds"
echo "  - Protocol: gRPC"
echo ""

# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Configure exporter type (CRITICAL - without this, metrics won't be sent!)
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# Configure OTLP endpoint with gRPC
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:14317
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc

# Set faster export interval for testing
export OTEL_METRIC_EXPORT_INTERVAL=10000
export OTEL_LOGS_EXPORT_INTERVAL=5000

echo "Environment variables set!"
echo ""
echo "Now start Claude Code manually with:"
echo "  claude"
echo ""
echo "After using Claude Code for a while, check metrics with:"
echo "  ./check-metrics.sh"
echo ""

# Start Claude Code manually in this shell
# All environment variables are now set
