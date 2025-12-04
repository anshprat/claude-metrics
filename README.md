# Claude Code - Token Usage & Cost Tracking

This directory contains a complete OpenTelemetry-based metrics collection system for tracking Claude Code token usage and costs. The system uses Docker Compose to run Prometheus (metrics storage), Grafana (visualization), and OpenTelemetry Collector (metrics ingestion).

## Architecture

```
Claude Code → OpenTelemetry Collector → Prometheus → Grafana Dashboard
               (port 4318/4317)        (storage)    (visualization)
```

## Prerequisites

- Docker and Docker Compose installed
- Claude Code installed and configured

## Quick Start

### Automated Setup (Recommended)

Run the automated setup script that checks prerequisites and starts everything:

```bash
./init.sh
```

This will:
- Check that Docker and Docker Compose are installed
- Verify Docker daemon is running
- Start all services
- Display configuration instructions

### Manual Setup

### 1. Start the Metrics Stack

```bash
./start.sh
```

This will:
- Start OpenTelemetry Collector, Prometheus, and Grafana in Docker containers
- Set up automatic data persistence using Docker volumes
- Display access URLs for all services

### 2. Configure Claude Code

**IMPORTANT:** Claude Code requires environment variables to properly export telemetry.

#### Option A: Source the telemetry script (Recommended)

```bash
# HTTP protocol (default)
source telemetry.sh
claude

# OR with parameters
source telemetry.sh --protocol=grpc                      # Use gRPC
source telemetry.sh --host=custom-host.com               # Custom host
source telemetry.sh --protocol=grpc --host=remote.com    # Both

# OR use the gRPC convenience wrapper
source telemetry-grpc.sh
claude
```

This script sets all required environment variables for your current shell session. Then start Claude Code normally.

#### Option B: Add to shell profile for persistence

Add these variables to your `~/.bashrc`, `~/.zshrc`, or equivalent:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp          # CRITICAL - tells Claude Code to export to OTLP
export OTEL_LOGS_EXPORTER=otlp             # CRITICAL - tells Claude Code to export logs to OTLP
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:14318
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_METRIC_EXPORT_INTERVAL=10000
export OTEL_LOGS_EXPORT_INTERVAL=5000
```

Then reload your shell:
```bash
source ~/.bashrc  # or ~/.zshrc
```

**Note:** For gRPC protocol instead of HTTP, use `source telemetry-grpc.sh` (Option A) or see the telemetry-grpc.sh file for the appropriate environment variables (Option B).

### 3. View the Dashboard

```bash
./view.sh
```

Or manually navigate to: http://localhost:3000/d/claude-code-metrics

Default credentials:
- Username: `admin`
- Password: `admin`

## Management Scripts

All operations are managed through shell scripts:

| Script | Description |
|--------|-------------|
| `./init.sh` | Complete automated setup (checks prerequisites and starts stack) |
| `./start.sh` | Start the entire metrics collection stack |
| `./stop.sh` | Stop the stack (preserves data) |
| `./view.sh` | Open Grafana dashboard in your browser |
| `./status.sh` | Check health status of all services |
| `./logs.sh` | View logs from all services |
| `source telemetry.sh` | Set telemetry environment variables (HTTP) for current session |
| `source telemetry-grpc.sh` | Set telemetry environment variables (gRPC) for current session |
| `./metrics.sh` | Check metrics collection and verify data flow |

### Viewing Logs

```bash
# View all logs
./logs.sh

# View specific service logs
./logs.sh otel        # OpenTelemetry Collector
./logs.sh prometheus  # Prometheus
./logs.sh grafana     # Grafana
```

## Services & Ports

| Service | URL | Description |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | Metrics visualization dashboard |
| Prometheus | http://localhost:9090 | Metrics storage and query interface |
| OpenTelemetry (HTTP) | http://localhost:14318 | Metrics ingestion endpoint |
| OpenTelemetry (gRPC) | http://localhost:14317 | Alternative metrics endpoint |

## Metrics Tracked

The dashboard displays all 8 official Claude Code metrics as documented at https://code.claude.com/docs/en/monitoring-usage:

### Key Summary Metrics
- **Total Cost (USD)** - Cumulative cost of all API calls (claude_code.cost.usage)
- **Total Sessions** - Number of CLI sessions started (claude_code.session.count)
- **Total Active Time** - Actual active usage time in seconds (claude_code.active_time.total)

### Token Metrics
- **Total Input Tokens** - Cumulative input tokens consumed
- **Total Output Tokens** - Cumulative output tokens generated
- **Cache Read Tokens** - Tokens read from prompt cache
- **Cache Creation Tokens** - Tokens used to create cache entries
- **Token Rate** - Real-time token consumption per second (all types)

### Activity Metrics
- **Commits** - Git commits created via Claude Code (claude_code.commit.count)
- **Pull Requests** - PRs created via Claude Code (claude_code.pull_request.count)
- **Lines Added/Removed** - Code modifications tracked (claude_code.lines_of_code.count)
- **Code Edit Tool Decisions** - User acceptance/rejection of edits (claude_code.code_edit_tool.decision)

### Time-Series Graphs
- **Cost Over Time by Model** - Hourly cost breakdown per model
- **Token Usage Over Time** - Hourly token consumption (input, output, cache read, cache creation)
- **Activity Over Time** - Sessions, commits, and PRs over time
- **Code Changes Over Time** - Lines added/removed per hour

## Data Persistence

All metrics data is stored in Docker volumes and persists across container restarts:
- `prometheus-data` - Stores all historical metrics
- `grafana-data` - Stores dashboard configurations and settings

### Removing All Data

To completely remove all collected data:

```bash
./stop.sh
docker-compose down -v
```

## Troubleshooting

### Check Service Health

```bash
./status.sh
```

This will verify:
- Docker containers are running
- Services are responding to health checks
- Claude Code configuration is present

### View Service Logs

```bash
# All services
./logs.sh

# Specific service
./logs.sh otel
```

### No Metrics Appearing in Grafana

**Most Common Issue:** Missing `OTEL_METRICS_EXPORTER` environment variable!

1. **Verify ALL required environment variables are set:**
   ```bash
   env | grep -E '^OTEL_|^CLAUDE_CODE'
   ```

   You MUST see:
   ```
   CLAUDE_CODE_ENABLE_TELEMETRY=1
   OTEL_METRICS_EXPORTER=otlp      ← CRITICAL!
   OTEL_LOGS_EXPORTER=otlp         ← CRITICAL!
   OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:14318
   OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
   ```

2. Check OpenTelemetry Collector is receiving data:
   ```bash
   ./logs.sh otel
   ```

   Look for log lines showing metrics being received and exported.

3. Verify Prometheus is scraping metrics:
   - Open http://localhost:9090
   - Go to Status → Targets
   - Check that `otel-collector` target is "UP"

4. Check Prometheus has data:
   - Open http://localhost:9090
   - Run query: `claude_code_cost_usage_total` or `claude_code_token_usage_total`

5. If still no metrics, restart your Claude Code session with the proper environment variables using:
   ```bash
   source telemetry.sh
   claude
   ```

### Container Won't Start

Check for port conflicts:
```bash
# Check if ports are already in use
lsof -i :3000   # Grafana
lsof -i :9090   # Prometheus
lsof -i :14318  # OpenTelemetry HTTP
lsof -i :14317  # OpenTelemetry gRPC
```

## Configuration Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Docker services orchestration |
| `otel-collector-config.yml` | OpenTelemetry Collector configuration |
| `prometheus.yml` | Prometheus scrape configuration |
| `claude-code-config.json` | Claude Code telemetry settings |
| `grafana/provisioning/` | Auto-provisioned data sources and dashboards |
| `grafana/dashboards/` | Pre-built dashboard definitions |

## Customization

### Adjusting Data Retention

Edit `prometheus.yml` and add to the `command` section in `docker-compose.yml`:

```yaml
command:
  - '--storage.tsdb.retention.time=30d'  # Keep data for 30 days
  - '--storage.tsdb.retention.size=10GB'  # Or max 10GB
```

### Modifying the Dashboard

1. Log into Grafana (http://localhost:3000)
2. Navigate to the Claude Code dashboard
3. Make your changes
4. Export the dashboard (Share → Export → Save to file)
5. Replace `grafana/dashboards/claude-code-metrics.json` with the exported file

### Adding Custom Metrics

Edit `otel-collector-config.yml` to add processors or exporters as needed. See the [OpenTelemetry Collector documentation](https://opentelemetry.io/docs/collector/) for more options.

## Cost Metrics Accuracy

The costs displayed are **approximations** based on Claude Code's internal calculations. For official billing records, consult:
- [Claude Console](https://console.anthropic.com/claude-code) (for direct API usage)
- AWS Bedrock billing (if using AWS)
- Google Cloud Vertex AI billing (if using GCP)

## Accessing Historical Data via API

You can query Prometheus directly for historical data:

```bash
# Get total cost over the last hour
curl 'http://localhost:9090/api/v1/query?query=claude_code_total_cost_dollars'

# Get token usage over time (last 24h)
curl 'http://localhost:9090/api/v1/query_range?query=claude_code_input_tokens_total&start=2024-01-01T00:00:00Z&end=2024-01-02T00:00:00Z&step=1h'
```

See [Prometheus HTTP API documentation](https://prometheus.io/docs/prometheus/latest/querying/api/) for more query options.

## Security Notes

- Default Grafana credentials (`admin`/`admin`) should be changed in production
- This setup is designed for local development use
- For production deployments, consider:
  - Adding authentication to Prometheus and OpenTelemetry endpoints
  - Using TLS/SSL certificates
  - Implementing network isolation
  - Setting up proper backup procedures

## Support

For issues with:
- **Claude Code**: Visit the [Claude Code GitHub repository](https://github.com/anthropics/claude-code)
- **This setup**: Check the troubleshooting section above or review service logs

## License

This configuration is provided as-is for use with Claude Code. Modify as needed for your specific requirements.
