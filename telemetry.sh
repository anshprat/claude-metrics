#!/bin/bash

# Start Claude Code with telemetry enabled and configured for local OTLP collector
# Usage:
#   ./telemetry.sh                                    # defaults to HTTP on localhost
#   ./telemetry.sh --protocol=http
#   ./telemetry.sh --protocol=grpc
#   ./telemetry.sh --host=custom-host.com
#   ./telemetry.sh --protocol=grpc --host=custom-host.com

# Parse arguments
PROTOCOL="http"
HOST="localhost"
for arg in "$@"; do
  case $arg in
    --protocol=*)
      PROTOCOL="${arg#*=}"
      shift
      ;;
    --host=*)
      HOST="${arg#*=}"
      shift
      ;;
  esac
done

# Validate protocol
if [[ "$PROTOCOL" != "http" && "$PROTOCOL" != "grpc" ]]; then
  echo "Error: Invalid protocol '$PROTOCOL'. Must be 'http' or 'grpc'."
  exit 1
fi

# Set port and protocol based on argument
if [ "$PROTOCOL" = "grpc" ]; then
  PORT=14317
  PROTOCOL_FULL="grpc"
else
  PORT=14318
  PROTOCOL_FULL="http/protobuf"
fi

echo "Starting Claude Code with telemetry enabled..."
echo ""
echo "Configuration:"
echo "  - OTLP Endpoint: http://$HOST:$PORT"
echo "  - Export Interval: 10 seconds (for quick feedback)"
echo "  - Protocol: $PROTOCOL_FULL"
echo ""

# Enable telemetry
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# Configure exporter type (CRITICAL - without this, metrics won't be sent!)
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# Configure OTLP endpoint
export OTEL_EXPORTER_OTLP_ENDPOINT=http://$HOST:$PORT
export OTEL_EXPORTER_OTLP_PROTOCOL=$PROTOCOL_FULL

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
