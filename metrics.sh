#!/bin/bash

# Script to check if all Claude Code metrics are present in Prometheus
# Based on: https://code.claude.com/docs/en/monitoring-usage

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Prometheus URL
PROMETHEUS_URL="${PROMETHEUS_URL:-http://localhost:9090}"

# Define all expected metrics from the documentation (metric|description)
# Note: Counter metrics get _total suffix when exported to Prometheus
EXPECTED_METRICS=(
    "claude_code_session_count_total|Count of CLI sessions started"
    "claude_code_lines_of_code_count_total|Count of lines of code modified"
    "claude_code_pull_request_count_total|Number of pull requests created"
    "claude_code_commit_count_total|Number of git commits created"
    "claude_code_cost_usage_USD_total|Cost of the Claude Code session (USD)"
    "claude_code_token_usage_tokens_total|Number of tokens used"
    "claude_code_code_edit_tool_decision_total|Count of code editing tool permission decisions"
    "claude_code_active_time_seconds_total|Actual time spent actively using Claude Code (seconds)"
)

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Claude Code Metrics Validation${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check for required dependencies
echo -e "${YELLOW}Checking required dependencies...${NC}"
MISSING_DEPS=()

if ! command -v curl &> /dev/null; then
    MISSING_DEPS+=("curl")
fi

if ! command -v jq &> /dev/null; then
    MISSING_DEPS+=("jq")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${RED}✗ Missing required dependencies: ${MISSING_DEPS[*]}${NC}"
    echo -e "${YELLOW}Please install the missing dependencies:${NC}"
    echo "  - macOS: brew install ${MISSING_DEPS[*]}"
    echo "  - Ubuntu/Debian: apt-get install ${MISSING_DEPS[*]}"
    echo "  - CentOS/RHEL: yum install ${MISSING_DEPS[*]}"
    exit 1
fi
echo -e "${GREEN}✓ All dependencies available${NC}"
echo ""

# Check if Prometheus is accessible
echo -e "${YELLOW}Checking Prometheus connectivity...${NC}"
if ! curl -s "${PROMETHEUS_URL}/-/healthy" > /dev/null 2>&1; then
    echo -e "${RED}✗ Cannot connect to Prometheus at ${PROMETHEUS_URL}${NC}"
    echo -e "${YELLOW}Make sure the containers are running: ./status.sh${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Prometheus is accessible${NC}"
echo ""

# Fetch all available metrics from Prometheus
echo -e "${YELLOW}Fetching available metrics from Prometheus...${NC}"
METRICS_RESPONSE=$(curl -s "${PROMETHEUS_URL}/api/v1/label/__name__/values")

if [ $? -ne 0 ] || [ -z "$METRICS_RESPONSE" ]; then
    echo -e "${RED}✗ Failed to fetch metrics from Prometheus${NC}"
    exit 1
fi

AVAILABLE_METRICS=$(echo "$METRICS_RESPONSE" | jq -r '.data[]' 2>/dev/null)

if [ -z "$AVAILABLE_METRICS" ]; then
    echo -e "${RED}✗ Could not parse metrics from Prometheus response${NC}"
    echo -e "${YELLOW}Response was: ${METRICS_RESPONSE}${NC}"
    exit 1
fi

# Count total metrics
TOTAL_METRICS=$(echo "$AVAILABLE_METRICS" | wc -l | tr -d ' ')
echo -e "${GREEN}✓ Found ${TOTAL_METRICS} total metrics in Prometheus${NC}"
echo ""

# Check each expected metric
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Checking Expected Metrics${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

FOUND_COUNT=0
MISSING_COUNT=0
MISSING_METRICS=()

for entry in "${EXPECTED_METRICS[@]}"; do
    metric="${entry%%|*}"
    description="${entry#*|}"

    if echo "$AVAILABLE_METRICS" | grep -q "^${metric}$"; then
        echo -e "${GREEN}✓${NC} ${metric}"
        echo -e "  ${description}"

        # Get sample data for the metric
        SAMPLE_DATA=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=${metric}" | jq -r '.data.result[0].value[1]' 2>/dev/null)
        if [ "$SAMPLE_DATA" != "null" ] && [ -n "$SAMPLE_DATA" ]; then
            echo -e "  ${BLUE}Current value: ${SAMPLE_DATA}${NC}"
        else
            echo -e "  ${YELLOW}No data points yet${NC}"
        fi
        echo ""
        FOUND_COUNT=$((FOUND_COUNT + 1))
    else
        echo -e "${RED}✗${NC} ${metric}"
        echo -e "  ${description}"
        echo -e "  ${RED}MISSING from Prometheus${NC}"
        echo ""
        MISSING_METRICS+=("$metric")
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

# Summary
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

EXPECTED_COUNT="${#EXPECTED_METRICS[@]}"
echo -e "Expected metrics:  ${EXPECTED_COUNT}"
echo -e "${GREEN}Found metrics:     ${FOUND_COUNT}${NC}"

if [ $MISSING_COUNT -gt 0 ]; then
    echo -e "${RED}Missing metrics:   ${MISSING_COUNT}${NC}"
    echo ""
    echo -e "${YELLOW}Missing metrics list:${NC}"
    for metric in "${MISSING_METRICS[@]}"; do
        echo -e "  - ${metric}"
    done
    echo ""
    echo -e "${YELLOW}Possible reasons for missing metrics:${NC}"
    echo "  1. No Claude Code session has been started yet"
    echo "  2. The specific actions (commits, PRs, etc.) haven't occurred"
    echo "  3. Metrics retention period has expired"
    echo "  4. OpenTelemetry collector configuration issue"
    echo ""
    echo -e "${YELLOW}Troubleshooting steps:${NC}"
    echo "  1. Check if Claude Code is configured: cat claude-code-config.json"
    echo "  2. Check collector logs: ./logs.sh"
    echo "  3. Verify Claude Code is exporting to OTLP endpoint"
    echo "  4. Start a Claude Code session and perform some actions"
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ All expected metrics are present!${NC}"
    exit 0
fi
