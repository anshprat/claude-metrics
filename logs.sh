#!/bin/bash

# Script to view logs from the metrics collection stack
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Claude Code Metrics Collection - Logs"
echo "================================================"
echo ""
echo "Available options:"
echo "  1. All services (default)"
echo "  2. OpenTelemetry Collector only"
echo "  3. Prometheus only"
echo "  4. Grafana only"
echo ""

# Parse command line argument
SERVICE=""
case "${1:-1}" in
    1|all)
        SERVICE=""
        echo "Showing logs for ALL services..."
        ;;
    2|otel|collector)
        SERVICE="otel-collector"
        echo "Showing logs for OpenTelemetry Collector..."
        ;;
    3|prometheus)
        SERVICE="prometheus"
        echo "Showing logs for Prometheus..."
        ;;
    4|grafana)
        SERVICE="grafana"
        echo "Showing logs for Grafana..."
        ;;
    *)
        echo "Invalid option. Using default (all services)."
        SERVICE=""
        ;;
esac

echo "Press Ctrl+C to exit"
echo "================================================"
echo ""

# Follow logs
docker-compose logs -f $SERVICE
