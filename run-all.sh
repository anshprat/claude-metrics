#!/bin/bash

# Complete setup script - runs everything needed to get started
# This script will:
#   1. Run init.sh to set up the environment
#   2. Start the metrics collection stack
#   3. Display instructions for sourcing telemetry.sh
#
# Usage: ./run-all.sh [--protocol=http|grpc] [--host=hostname]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse arguments for telemetry configuration
TELEMETRY_ARGS=""
PROTOCOL="http"
HOST="localhost"

for arg in "$@"; do
  case $arg in
    --protocol=*)
      PROTOCOL="${arg#*=}"
      TELEMETRY_ARGS="$TELEMETRY_ARGS $arg"
      ;;
    --host=*)
      HOST="${arg#*=}"
      TELEMETRY_ARGS="$TELEMETRY_ARGS $arg"
      ;;
  esac
done

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         Claude Code Metrics - Complete Setup                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Run init.sh
echo "📦 Step 1/3: Running initial setup..."
echo "────────────────────────────────────────────────────────────────"
./init.sh
echo ""

# Step 2: Ensure services are running
echo "🚀 Step 2/3: Verifying services are running..."
echo "────────────────────────────────────────────────────────────────"
./status.sh
echo ""

# Step 3: Display telemetry setup instructions
echo "⚙️  Step 3/3: Telemetry Configuration"
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "To enable telemetry in Claude Code, run ONE of the following commands"
echo "in your terminal BEFORE starting Claude Code:"
echo ""

if [ "$PROTOCOL" = "grpc" ] && [ "$HOST" != "localhost" ]; then
  echo "  source telemetry.sh --protocol=grpc --host=$HOST"
  echo "  # OR"
  echo "  source telemetry-grpc.sh --host=$HOST"
elif [ "$PROTOCOL" = "grpc" ]; then
  echo "  source telemetry.sh --protocol=grpc"
  echo "  # OR"
  echo "  source telemetry-grpc.sh"
elif [ "$HOST" != "localhost" ]; then
  echo "  source telemetry.sh --host=$HOST"
else
  echo "  source telemetry.sh                    # HTTP (default)"
  echo "  source telemetry.sh --protocol=grpc   # gRPC"
  echo "  source telemetry-grpc.sh              # gRPC (shorthand)"
fi

echo ""
echo "Then start Claude Code:"
echo "  claude"
echo ""
echo "────────────────────────────────────────────────────────────────"
echo ""
echo "✅ Setup complete! Next steps:"
echo ""
echo "  1. Run: source telemetry.sh$TELEMETRY_ARGS"
echo "  2. Run: claude"
echo "  3. Use Claude Code for a bit"
echo "  4. Run: ./view.sh (to see the dashboard)"
echo "  5. Run: ./metrics.sh (to check metrics collection)"
echo ""
echo "Dashboard will be available at: http://localhost:3000"
echo "Default credentials: admin / admin"
echo ""
