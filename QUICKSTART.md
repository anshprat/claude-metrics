# Quick Reference - Claude Code Metrics

## First Time Setup

```bash
# 1. Run automated setup
./setup.sh

# 2. Configure Claude Code (add to ~/.bashrc or ~/.zshrc)
export CLAUDE_CODE_CONFIG=~/code/anshprat/claude-billing/claude-code-config.json

# 3. Reload shell or run:
source ~/.bashrc  # or ~/.zshrc
```

## Daily Usage

```bash
# Start metrics collection
./start.sh

# View dashboard
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
1. Check Claude Code config: `echo $CLAUDE_CODE_CONFIG`
2. Verify services are running: `./status.sh`
3. Check OTel logs: `./logs.sh otel`

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
