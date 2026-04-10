# Lab 02: MCP Servers

**Duration:** ~20 minutes  
**Goal:** Understand what MCP servers are, see what's already connected in this environment, and understand what additional capabilities they unlock for Assistant.

---

## Background

**MCP (Model Context Protocol)** is an open standard that lets AI assistants connect to external tools and systems. Think of MCP servers as plugins — each one gives Assistant a new set of things it can *do*, not just things it can *know*.

Without MCP, Assistant answers questions based on what it can read from your Grafana data sources. **With MCP**, it can take action in external systems — search a GitHub repo, query an external API, interact with tools your team already uses.

Grafana Assistant has MCP configured in **Settings → Integrations**. The Grafana platform itself is always available as a built-in capability (searching dashboards, reading panels, creating alerts). MCP servers extend that further.

---

## Step 1: See What's Connected

1. In the left sidebar, click **Assistant** → **Settings** → **Integrations**.

   This is the MCP servers page.

2. You'll see any currently configured MCP servers. In this workshop environment, you should see a **Kubernetes** MCP server listed as **healthy** with **8 of 8 tools enabled**.

   > **Note for self-hosted teams:** In your own environment, you'd configure MCP servers relevant to your team — GitHub for repo context, PagerDuty or Linear for incident tracking, or a custom server for your internal tooling.

3. Scroll down to the **Quick setup** section. You'll see a search bar and a catalog of popular pre-configured servers including:
   - **GitHub** — search repos, triage pull requests, manage issues
   - **Honeycomb** — trace requests and debug production issues
   - **Cloudflare Observability** — query Cloudflare telemetry for edge/platform issues
   - **PagerDuty** — manage incidents, on-call schedules, and escalations
   - Plus an **Add custom server** option for your own MCP endpoints

---

## Step 2: See What Tools Are Available

Now let's ask Assistant what it can actually do.

1. Go back to the main Assistant page (click **Assistant** in the sidebar).

2. Type:

   ```
   What tools do you have available?
   ```

   Assistant will list its capabilities. You should see Grafana-native tools like:
   - Search dashboards
   - Get and update dashboard JSON
   - List and create alert rules
   - Query data sources
   - Access Kubernetes resources (from the MCP server)

---

## Step 3: Use a Built-in Tool

Assistant's Grafana capabilities are always available without extra configuration. Let's use one.

1. Ask Assistant to find a specific dashboard:

   ```
   Find me a dashboard that shows error rates for the telescope shop services
   ```

   Assistant will search your Grafana instance and return matching dashboards with names and links.

2. Click one of the returned links. It should take you directly to that dashboard.

3. Come back to Assistant and ask:

   ```
   What query is powering the main error rate panel on that dashboard?
   ```

   Assistant can read the panel configuration and explain the query in plain English.

---

## Step 4: The Practical Value

Ask Assistant a question that benefits from having live access to your Grafana instance:

```
How many dashboards are in this Grafana instance, and which folders are they in?
```

This isn't a question Assistant can answer from memory — it requires querying your instance directly. With MCP/built-in tools, it can.

---

## What MCP Unlocks for Self-Hosted Teams

For a team running their own Loki, Mimir, and Tempo, the key value is:

- **No context-switching** — ask about your dashboards, alerts, and data without leaving the conversation
- **Live answers** — results come from your actual instance, not cached knowledge
- **External integrations** — connect GitHub, Jira, Linear, or your own internal tools so Assistant can cross-reference observability data with code changes, tickets, or runbooks

MCP is how Grafana Assistant becomes a colleague who can look things up and take action, not just answer questions.

---

## Checkpoint

Before moving on, confirm:

- [ ] You found the MCP servers page at Settings → Integrations
- [ ] You verified the Kubernetes MCP server is healthy with 8 tools
- [ ] You asked Assistant what tools it has and saw the list
- [ ] You used Assistant to find and link to a real dashboard

---

**Next:** [Lab 03 — Queries & Dashboards](./03-queries-and-dashboards.md)
