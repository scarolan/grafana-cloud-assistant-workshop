# Lab 03: Queries & Dashboards

**Duration:** ~40 minutes  
**Goal:** Use Grafana Assistant to query your data in plain English, understand dashboards you didn't build, and create a new dashboard from a description.

---

## Background

One of the highest-friction parts of observability is the query language barrier. PromQL, LogQL, and TraceQL are powerful — but they take time to learn, and even experienced users spend time looking up syntax.

Grafana Assistant lets you skip the syntax and describe what you want. It translates your intent into the right query, runs it, and shows you the result. You can then ask it to explain what it found, adjust the time range, or build a panel around it.

---

## How the Conversation Works

Before diving in — a quick orientation to the conversation interface:

- Your message appears as a **dark rounded bubble** at the top of the response
- Assistant shows its **reasoning steps** as collapsible `>` items (e.g., `Searched 3x, Queries 4x`) — click to expand and see each tool call. Between steps, Assistant writes brief intermediate reasoning in plain text so you can follow its logic.
- For **metrics queries**, the response includes an **inline time-series chart** with the PromQL query shown in the chart legend
- At the bottom of each response you'll see **Follow-up** chips — click them to continue without typing. Some responses also show a **Relevant logs** column with direct links into Explore.
- The **`@` symbol** in the right panel input opens a context picker where you can attach a specific data source, dashboard, or panel
- Type **`/`** in the input to access slash commands

---

## Part A: Natural Language Queries

### Step 1: Query Logs in Plain English

1. Open Grafana Assistant from the left sidebar.

2. Start broad — let Assistant find whatever is interesting:

   ```
   Show me error and critical logs from the last 6 hours
   ```

   Assistant will run a LogQL query against Loki and return matching log lines. The telescope shop has ongoing background issues — you should see database errors, connection failures, or gRPC initialization problems. Watch how Assistant adapts if its first query attempt doesn't match the log format.

3. Follow up with:

   ```
   Are there any patterns in these errors? Group them by type.
   ```

   Assistant will analyze the results and summarize: common error messages, which services produced them, and whether they're clustered in time or spread out.

4. Try narrowing to a specific signal:

   ```
   Show me only logs that mention "connection" in the last 6 hours
   ```

   This should surface connection refused errors and gRPC connection failures — a common pattern when database pods restart.

---

### Step 2: Query Metrics in Plain English

1. Ask a question that surfaces a real problem:

   ```
   Which service has the highest P95 latency right now?
   ```

   Assistant will query Mimir/Prometheus and return results with an **inline time-series chart**. The checkout service typically shows elevated latency (~400–900ms) — much higher than other services. The PromQL query appears in the chart legend — this is how you learn the actual query syntax.

2. Dig deeper:

   ```
   How does checkout latency compare to the other services?
   ```

3. Now check error rates across the board:

   ```
   Which services have the highest error rates right now?
   ```

   This is a broad query that shows Assistant searching multiple metric types. Watch how it tries different approaches (HTTP status codes, span status codes, error ratios) to find the most relevant answer.

---

### Step 3: Explore Traces

1. Follow the latency you discovered in Step 2:

   ```
   Show me the slowest traces from the checkout service in the last hour
   ```

   Assistant will query Tempo and return trace IDs with their durations. You should see some traces with several hundred milliseconds of latency.

2. Ask the key question:

   ```
   In those traces, which service or span is adding the most latency?
   ```

   This reveals the bottleneck — often a downstream database call or a dependent service. This is the same detective flow you'd use in a real incident.

---

## Part B: Understanding Existing Dashboards

### Step 4: "Explain This Panel"

1. Navigate to any pre-loaded dashboard in the AppEnv folder.

2. Find a panel that looks interesting or confusing — a graph, a stat, or a table.

3. Open Assistant and ask:

   ```
   Explain what the panel called "[panel name]" is showing me
   ```

   Replace `[panel name]` with the actual panel name from the dashboard.

   Assistant will read the panel's query via MCP and explain it in plain English: what metric it's measuring, what the axes mean, what a spike or dip would indicate.

4. Ask a follow-up:

   ```
   Is the current value good or bad?
   ```

   Assistant will interpret the value in context — using thresholds, historical data, or general knowledge about the metric.

---

### Step 5: Understand an Unfamiliar Dashboard

1. Open a dashboard in the AppEnv folder that you haven't looked at before.

2. Ask Assistant:

   ```
   Give me a one-paragraph summary of what this dashboard is monitoring
   ```

   This is useful for onboarding — you can hand someone an unfamiliar dashboard and get oriented instantly.

---

## Part C: Building a Dashboard

### Step 6: Create a Dashboard from a Description

1. Think about what you'd want to monitor for the appenv checkout service. Something like: request rate, error rate, and latency (the classic "RED" metrics — Rate, Errors, Duration).

2. Ask Assistant:

   ```
   Create a dashboard in my personal folder called "Checkout Service RED Metrics" with three panels: 
   request rate, error rate, and p95 latency for the checkout service. 
   Use the last 6 hours as the default time range.
   ```

   > **Why 6 hours?** The checkout service has intermittent issues caused by the daily outage. A 6-hour window gives you enough history to see the pattern, rather than a flat line during a quiet period.

   Replace "my personal folder" with the folder name you created in Lab 00.

3. Assistant will use MCP to create the dashboard directly in your Grafana instance. When it's done, it will give you a link. Click it.

4. Verify the dashboard loaded correctly and the panels have data.

---

### Step 7: Refine the Dashboard

1. Back in Assistant, ask:

   ```
   Add a fourth panel showing the number of active cart sessions
   ```

2. Then:

   ```
   Change the panel colors so that high error rates show in red
   ```

3. Each time, verify the change appeared in the dashboard.

---

## Checkpoint

Before moving on, confirm:

- [ ] You queried Loki logs using plain English and got results
- [ ] You queried Mimir metrics and understood the PromQL Assistant generated
- [ ] You used "explain this panel" on an existing dashboard
- [ ] You created a new dashboard via Assistant with at least 3 panels
- [ ] The dashboard is saved in your personal folder

---

**Next:** [Lab 04 — Investigation](./04-investigation.md)
