# Quick Reference - Claude Code Metrics

## First Time Setup

### Option 1: One Command (Easiest)
```bash
./run-all.sh
# Then follow the instructions to source telemetry.sh and start claude
```

### Option 2: Step by Step
```bash
# 1. Run automated setup
./init.sh

# 2. Configure telemetry environment variables
# Option A: Add to ~/.bashrc or ~/.zshrc for persistence
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:14318
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
export OTEL_METRIC_EXPORT_INTERVAL=10000
export OTEL_LOGS_EXPORT_INTERVAL=5000

# Then reload shell
source ~/.bashrc  # or ~/.zshrc

# Option B: Source telemetry.sh before each Claude session (no profile changes)
# See "Daily Usage" section below
```

## Daily Usage

```bash
# Start metrics collection stack
./start.sh

# Set telemetry environment variables for current session
source telemetry.sh                    # HTTP protocol (default)
# OR
source telemetry.sh --protocol=grpc   # gRPC protocol
# OR
source telemetry.sh --protocol=http --host=custom-host.com  # Custom host

# Alternatively, use the gRPC convenience wrapper
source telemetry-grpc.sh

# Start Claude Code
claude

# View dashboard (in another terminal)
./view.sh

# Check status
./status.sh

# Stop when done
./stop.sh
```

## Access URLs

- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **OpenTelemetry**: http://localhost:4318

## Troubleshooting

```bash
# Check service health
./status.sh

# View all logs
./logs.sh

# View specific service logs
./logs.sh otel
./logs.sh prometheus
./logs.sh grafana
```

## Common Issues

### No metrics showing up?
1. Check telemetry variables are set: `env | grep -E '^OTEL_|^CLAUDE_CODE'`
2. Verify services are running: `./status.sh`
3. Check metrics collection: `./metrics.sh`
4. Check OTel logs: `./logs.sh otel`

### Port already in use?
```bash
# Find process using port 3000 (Grafana)
lsof -i :3000

# Or 9090 (Prometheus)
lsof -i :9090
```

### Reset everything?
```bash
./stop.sh
docker-compose down -v  # Warning: deletes all data!
./start.sh
```

## API Queries

Query Prometheus directly:

```bash
# Total cost
curl 'http://localhost:9090/api/v1/query?query=claude_code_total_cost_dollars'

# Token counts
curl 'http://localhost:9090/api/v1/query?query=claude_code_input_tokens_total'
curl 'http://localhost:9090/api/v1/query?query=claude_code_output_tokens_total'
```

For more details, see **README.md**
