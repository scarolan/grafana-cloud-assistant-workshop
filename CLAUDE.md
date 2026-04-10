# CLAUDE.md — Workshop Builder Guide

You are maintaining a half-day hands-on workshop that teaches **Grafana Assistant** — the agentic LLM assistant built into Grafana Cloud. The workshop uses a shared environment with live data; there is no local infrastructure to build or manage.

## What This Repo Is

Five prescriptive markdown labs that walk students through Grafana Assistant features using a live **appenv** environment (a telescope shop e-commerce app). Students log into a shared Grafana Cloud stack, query real telemetry, and investigate real incidents — all through the Assistant UI.

This is **not** a demo builder. There are no Docker containers, no Alloy pipelines, no Terraform resources. The appenv environment is provisioned separately by the SE before the workshop.

## Target Audience

Teams evaluating or onboarding to Grafana Cloud, including those running self-hosted OSS Loki, Mimir, and Tempo. The workshop demonstrates value without relying on cloud-native features like App O11y, Kubernetes O11y, or Knowledge Graph — so it works for any customer regardless of their current stack.

## Environment

- **Stack:** Shared Grafana Cloud instance (URL provided by instructor)
- **Data:** appenv generates metrics, logs, and traces from 15+ microservices continuously
- **Outage:** A scheduled daily outage creates real incidents (payment timeouts, DB connection exhaustion, pod restarts) for Lab 04
- **Auth:** Students log in via Grafana Cloud credentials; each creates a personal folder to avoid collisions
- **Features in scope:** Assistant conversations, memories/infra scan, custom rules, MCP servers (Kubernetes), natural language queries, dashboard creation, Investigations (Public Preview)
- **Features out of scope:** Knowledge Graph (OFF), App O11y, Kubernetes O11y, Pyroscope, any cloud-only features

## Lab Structure

| Lab | File | Duration | Focus |
|-----|------|----------|-------|
| 00 | `labs/00-getting-started.md` | ~15 min | Login, orientation, first message |
| 01 | `labs/01-memories-infra-scan.md` | ~30 min | Discovery scan, custom rules |
| 02 | `labs/02-mcp-servers.md` | ~20 min | MCP integrations, tool discovery |
| 03 | `labs/03-queries-and-dashboards.md` | ~40 min | NL queries, explain panels, build dashboards |
| 04 | `labs/04-investigation.md` | ~60 min | Incident investigation + multi-agent swarm |

## Writing Lab Content

### Principles
1. **Prescriptive, not exploratory** — "Type this, click that, see this result." Not "explore on your own."
2. **Every query should produce interesting results** — Target services with real data (checkout latency, database errors, frontend traffic). Avoid quiet services that return empty.
3. **Use broad time ranges** — The daily outage timing varies. Use "last 6 hours" or "last 24 hours" so students always find evidence.
4. **Describe the actual UI** — Button names, navigation paths, and panel layouts must match the live Grafana Assistant UI. When in doubt, verify with the Chrome extension.
5. **Include "What to look for" hints** — Students need to know what a good result looks like so they don't get stuck.

### Lab Format
Every lab must have:
- A `# Title` (H1)
- `**Duration:**` and `**Goal:**` on the first lines
- A `## Checkpoint` section with checkbox items at the end
- A `**Next:**` link to the following lab (except Lab 04)
- Code blocks with the exact text students should type

### Known Data Patterns
The appenv telescope shop reliably produces:
- **Checkout service:** High P95 latency (~400–900ms), pod restarts across regions
- **Database:** SQL syntax errors, connection refused errors, gRPC initialization failures
- **Frontend/flagd:** Highest traffic volume (~4 req/s for flagd, ~0.8 req/s for frontend)
- **Payment service:** Usually healthy (low traffic, info-level logs only)
- **Kubernetes MCP server:** Occasional error spikes (11-14%), resolves quickly

### Grafana Assistant UI Reference
- Assistant is a **full-page app** at `/a/grafana-assistant-app`
- The **right panel** (conversation) is always visible; it shows suggested prompts when idle
- User messages appear in **dark rounded bubbles** (not green)
- **Reasoning steps** show as collapsible `>` items with inline intermediate text
- **Metrics responses** include inline time-series charts with PromQL in the legend
- **Follow-up chips** appear at the bottom of each response; some responses also show "Relevant logs" links
- The **gear icon** in the input opens a dropdown: Rules, MCP servers, Settings
- The **`@` symbol** opens a data source context picker
- **Investigations** mode (Public Preview) uses 20-25 specialist agents, shows a Gantt chart, and produces Key Findings with Root Causes and Recommendations

## Testing

### Automated Tests (BATS)
```bash
make test      # Run all 34 tests (content + stack + data)
make content   # Markdown structure and links only (no auth needed)
make preflight # Stack health (needs GRAFANA_WORKSHOP_URL + GRAFANA_SA_TOKEN)
make data      # Data quality (needs SA token with datasource proxy access)
```

### AI-Powered QA (Claude Code + Chrome)
```bash
make qa        # Full walkthrough — run the day before delivery
```

The QA script walks through every lab as a student, types actual queries into Assistant, and reports a pass/fail table.

### Environment Variables for Tests
Set these as env vars or in a `.env` file (gitignored):
- `GRAFANA_WORKSHOP_URL` — the Grafana Cloud stack URL
- `GRAFANA_SA_TOKEN` — service account token with Admin or Viewer role
- `GRAFANA_PROM_UID` — Prometheus data source UID (default: `grafanacloud-prom`)
- `GRAFANA_LOKI_UID` — Loki data source UID (default: `grafanacloud-logs`)

## DO NOT

- **Do not add Docker, Terraform, or infrastructure** — this repo has no local services
- **Do not reference cloud-only features** — no App O11y, Kubernetes O11y, Knowledge Graph
- **Do not hardcode the stack URL** — it changes per workshop delivery
- **Do not write "choose your own adventure" labs** — be prescriptive
- **Do not target quiet services** — payment service has no errors; use checkout, frontend, or flagd
- **Do not use narrow time ranges** — "last hour" may miss the outage; prefer "last 6 hours"
- **Do not commit `.env` files** — `.gitignore` prevents this
