#!/bin/bash

# Start Claude Code with telemetry enabled and configured for local OTLP collector
# Usage: ./start-claude-with-telemetry.sh

echo "Starting Claude Code with telemetry enabled..."
echo ""
echo "Configuration:"
echo "  - OTLP Endpoint: http://localhost:14318"
echo "  - Export Interval: 10 seconds (for quick feedback)"
echo "  - Protocol: HTTP"
echo ""

# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Configure exporter type (CRITICAL - without this, metrics won't be sent!)
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# Configure OTLP endpoint
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:14318
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf

# Set faster export interval for testing (10 seconds instead of default 60)
export OTEL_METRIC_EXPORT_INTERVAL=10000
export OTEL_LOGS_EXPORT_INTERVAL=5000

# Optional: Uncomment to see metrics in console for debugging
# export OTEL_METRICS_EXPORTER=console
# export OTEL_LOGS_EXPORTER=console

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
