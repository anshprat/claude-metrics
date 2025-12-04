#!/bin/bash

# Test Claude Code telemetry by exporting to console
# This will show metrics in the terminal to verify they're being generated

echo "Testing Claude Code telemetry..."
echo "Metrics will print to console every 10 seconds"
echo ""
echo "Press Ctrl+C to stop and return to normal"
echo ""

# Enable telemetry with console exporter
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=console
export OTEL_METRIC_EXPORT_INTERVAL=10000

echo "Starting Claude Code with console metrics export..."
echo "===================================================="
echo ""

#exec claude
