#!/bin/bash

# Script to set executable permissions on all management scripts
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Setting executable permissions on scripts..."

chmod +x start.sh
chmod +x stop.sh
chmod +x view.sh
chmod +x logs.sh
chmod +x status.sh
chmod +x telemetry.sh
chmod +x telemetry-grpc.sh
chmod +x metrics.sh

echo "✅ All scripts are now executable!"
echo ""
echo "Available scripts:"
echo "  - ./start.sh          - Start the metrics collection stack"
echo "  - ./stop.sh           - Stop the metrics collection stack"
echo "  - ./view.sh           - Open Grafana dashboard in browser"
echo "  - ./logs.sh           - View logs from services"
echo "  - ./status.sh         - Check status of all services"
echo "  - ./telemetry.sh      - Source to set telemetry environment variables"
echo "  - ./telemetry-grpc.sh - Source to set telemetry variables (gRPC)"
echo "  - ./metrics.sh        - Check metrics collection status"
