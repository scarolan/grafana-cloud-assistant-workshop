# Grafana Assistant Workshop

A half-day, hands-on workshop teaching field engineers and customers how to use **Grafana Assistant** — the agentic LLM assistant built into Grafana Cloud.

## Target Audience

The **"Wiley" persona**: teams running self-hosted OSS Loki, Mimir, and Tempo who need to see the value of a Grafana Cloud subscription. No cloud-native features required — this workshop focuses on capabilities that work with any Prometheus/Loki/Tempo stack.

## Workshop Environment

The workshop uses **appenv** — a realistic e-commerce application (a telescope shop) running on a shared Grafana Cloud stack. Students don't install or configure anything. The data is already flowing.

- **Stack:** Shared Grafana Cloud instance (provided by instructor)
- **Data:** 15+ microservices generating metrics, logs, and traces continuously
- **Outage:** A scheduled daily outage creates real incidents for the investigation lab

## Labs

| # | Lab | Duration | What Students Learn |
|---|-----|----------|-------------------|
| 00 | [Getting Started](labs/00-getting-started.md) | ~15 min | Log in, create a personal folder, orient to the environment, send first message to Assistant |
| 01 | [Memories & Infra Scan](labs/01-memories-infra-scan.md) | ~30 min | Run a discovery scan, understand memories vs. custom rules, see how context improves answers |
| 02 | [MCP Servers](labs/02-mcp-servers.md) | ~20 min | See what MCP servers are connected, understand what tools Assistant has available |
| 03 | [Queries & Dashboards](labs/03-queries-and-dashboards.md) | ~40 min | Query logs/metrics/traces in plain English, explain existing panels, build a dashboard from a description |
| 04 | [Investigation](labs/04-investigation.md) | ~60 min | Investigate a real incident from vague complaint to root cause, launch a formal multi-agent Investigation |

**Total:** ~2.5–3 hours of hands-on lab time

## Prerequisites

### For Students
- A modern web browser (Chrome recommended)
- Credentials provided by the instructor

### For Instructors
| Tool | Required | Purpose |
|------|----------|---------|
| BATS | Yes | Automated preflight tests |
| Claude Code | Recommended | AI-powered QA before delivery |

## Instructor Setup

### 1. Provision the environment

Ensure an appenv instance is running and generating telemetry on a Grafana Cloud stack. See [grafana/appenv](https://github.com/grafana/appenv) for setup.

### 2. Configure credentials

```bash
cp .env.example .env
# Fill in GRAFANA_WORKSHOP_URL, GRAFANA_SA_TOKEN, and student credentials
```

### 3. Run preflight tests

```bash
make workshop-test       # 34 automated checks (content + stack + data)
```

### 4. Full QA (day before delivery)

```bash
make workshop-qa         # Claude Code walks through every lab in Chrome
```

## Testing

| Command | What it checks | Auth needed |
|---------|---------------|-------------|
| `make workshop-content` | Lab files exist, links resolve, structure valid, no placeholders | None |
| `make workshop-preflight` | Stack reachable, dashboards exist, data sources configured, Assistant installed | SA token |
| `make workshop-data` | Logs flowing, metrics present, checkout latency data, pod restarts | SA token |
| `make workshop-test` | All of the above | SA token |
| `make workshop-qa` | Full AI walkthrough of every lab via Claude Code + Chrome | Browser session |

The SA token needs a service account with **Admin** or **Viewer** role. Tests gracefully skip if permissions are insufficient.

## Repository Structure

```
labs/                          # Workshop lab exercises (markdown)
tests/
  workshop-content.bats        # Markdown structure validation
  workshop-preflight.bats      # Grafana stack health checks
  workshop-data.bats           # Data quality assertions
scripts/
  workshop-qa.sh               # Claude Code AI-powered QA
Makefile                       # Task runner (make help)
CLAUDE.md                      # Instructions for Claude Code
.env.example                   # Credential template
```
