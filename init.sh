#!/bin/bash

# Complete setup script for Claude Code metrics collection
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================"
echo "Claude Code Token Usage & Cost Tracking Setup"
echo "================================================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker from: https://docs.docker.com/get-docker/"
    exit 1
fi
echo "✅ Docker is installed"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "Please install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi
echo "✅ Docker Compose is installed"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running!"
    echo "Please start Docker and try again."
    exit 1
fi
echo "✅ Docker daemon is running"

echo ""
echo "All prerequisites met!"
echo ""
echo "================================================"
echo "Starting services..."
echo "================================================"
echo ""

# Start the stack
./start.sh

echo ""
echo "================================================"
echo "Configuration Instructions"
echo "================================================"
echo ""
echo "To enable metrics collection, configure Claude Code:"
echo ""
echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
echo ""
echo "  export CLAUDE_CODE_CONFIG=$SCRIPT_DIR/claude-code-config.json"
echo ""
echo "Or run this command for the current session:"
echo ""
echo "  export CLAUDE_CODE_CONFIG=$SCRIPT_DIR/claude-code-config.json"
echo ""
echo "================================================"
echo "Next Steps"
echo "================================================"
echo ""
echo "1. Configure Claude Code (see above)"
echo "2. Run some Claude Code commands"
echo "3. View metrics: ./view.sh"
echo ""
echo "For more information, see README.md"
echo "================================================"
