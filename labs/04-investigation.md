# Lab 04: Investigation

**Duration:** ~60 minutes  
**Goal:** Use Grafana Assistant to investigate a real incident — starting from a vague user complaint and working through logs, metrics, and traces to a root cause. Then launch a formal Investigation to see how multi-agent swarm mode works.

---

## Background

The telescope shop experiences a **scheduled daily outage** with a randomized delay. During this window, something in the stack degrades — payment timeouts, database connection exhaustion, memory pressure, or service latency. You won't know what it is until you look.

This lab has two parts:

- **Part A (GA):** Use the conversation interface to investigate step by step — this is the reliable, production-ready path.
- **Part B (Preview):** Launch a formal Investigation to see multi-agent parallel analysis in action.

---

## The Scenario

> **User report received:** "I've been trying to check out for the last 20 minutes and keep getting errors. Other people on my team are seeing the same thing."

That's all you know. Start there.

---

## Part A: Conversation-Based Investigation

### Step 1: Establish Scope

1. In the left sidebar, click **Assistant** to open the main page.

2. In the text input, type:

   ```
   Users are reporting checkout failures for the last 20 minutes. What services are showing elevated error rates right now?
   ```

3. Wait for the response. Assistant will query Mimir/Prometheus and return error rates by service. Notice that it shows its work — you'll see it running queries for error rates, P99 latency, and related metrics.

4. Look at the response table. Which services have elevated error rates? Note any with a **Status** that isn't OK.

> **Tip:** Each response includes **follow-up suggestion chips** at the bottom. These are context-aware — click them to keep the investigation moving without having to type the next question.

---

### Step 2: Follow the Errors

5. Click the follow-up chip for the service showing errors, or type:

   ```
   Show me error logs from [affected service] in the last 30 minutes
   ```

6. Ask Assistant to summarize:

   ```
   What are the most common error messages? Are they all the same type?
   ```

7. Pin down the timing:

   ```
   When did these errors start? Was it a sudden spike or gradual?
   ```

**What to look for:** Error message patterns that point to a specific cause — timeouts, connection refused, out of memory, 5xx from a downstream dependency.

---

### Step 3: Trace the Request Path

8. Switch to traces to find where the latency or failure is occurring:

   ```
   Show me traces for [affected service] requests that resulted in errors in the last 30 minutes
   ```

9. Ask:

   ```
   In these traces, which service or span is taking the most time or failing?
   ```

10. If a downstream service is implicated:

    ```
    Show me the health of [downstream service] — error rate, latency, and recent logs
    ```

**What to look for:** The specific span or service where requests are failing or timing out. This narrows the root cause to a single component.

---

### Step 4: Confirm the Root Cause

11. Ask Assistant to synthesize what you've found:

    ```
    Based on the error logs, traces, and metrics we've looked at — what do you think is causing the checkout failures?
    ```

12. Ask for supporting evidence:

    ```
    What metrics would confirm that hypothesis? Show me those.
    ```

---

### Step 5: Create an Alert Rule

Now that you know what to watch for, make sure you'd catch it faster next time.

13. Ask Assistant to create an alert:

    ```
    Create an alert rule that fires when the [affected service] error rate 
    exceeds 5% for more than 2 minutes. Name it appropriately.
    ```

14. Verify it was created:

    ```
    Show me the alert rule you just created
    ```

---

## Part B: Formal Investigation (Public Preview)

Investigation mode deploys a **Lead** agent that orchestrates a swarm of **specialist agents** in parallel — Prometheus Specialist, Loki Specialist, Loki Error Specialist, Tempo Specialist, MCP Specialist, and others — 20+ agents total depending on the incident. It produces a structured, shareable investigation workbook with root causes and recommendations.

> **Note:** Investigations is in **Public Preview**. The behavior is good but the canvas may take several minutes to fully populate. Clicking "Start investigation" changes the main page to **"Assistant Investigations"** mode.

### Step 6: Launch an Investigation

1. On the main Assistant page, find the **"Recent investigations"** section and click the **Start investigation** button in its top-right corner.

   The page switches to **"Assistant Investigations"** mode (Public Preview badge visible).

2. In the investigation input, describe the incident:

   ```
   The checkout service is slow and users are complaining. Investigate.
   ```

   Notice the **Deep Investigation** chip at the bottom of the input — this is the default mode.

3. Press **Enter**. The page navigates to a dedicated investigation URL (e.g., `/investigations/abc123`). This investigation is **saved and shareable**.

4. The Lead agent immediately spawns multiple specialist agents. You'll see the **Agent activity** section with a Gantt chart showing all agents running in parallel. Watch the count — a typical investigation uses 20–25 agents.

5. Click **"Provide more context"** to add information about the incident:

   ```
   Users started complaining about 20 minutes ago. Checkout and payment are both affected.
   ```

6. As agents complete their work, the **Key findings** section populates with:
   - **Executive Summary** — a narrative of what happened
   - **Hypotheses & Root Causes** — ranked contributing factors with evidence
   - **Recommendations** — prioritized actions (Critical / High / Medium)

### Step 7: Review the Investigation List

1. On the main Assistant page, click **Previous investigations** (or use the breadcrumb nav from inside an investigation).

2. You'll see your investigation listed. While running it shows **In Progress** with a progress count (e.g., `18/24`); when done it shows **Completed**.

3. Note it was automatically named from your prompt — "Checkout Service Slowness - Investigation Report" or similar.

4. The filter tabs let you see: **All | Completed | In Progress | Cancelled | Failed | Pending**

5. Click the investigation to return to its canvas. Use the **Detailed report**, **Tree View**, and **Timeline** tabs to explore findings from different angles.

---

## Debrief

Think about (or discuss with the group):

- At which point in Part A did you feel most confident about the root cause?
- How does the follow-up suggestion behavior change how you investigate vs. writing every query yourself?
- When would you use conversation mode vs. formal Investigation mode?
- What custom rule would you add after this incident to make future investigations start faster?

---

## Checkpoint

- [ ] In Part A: You identified which service(s) were affected using Assistant
- [ ] You used follow-up suggestion chips to keep the investigation moving
- [ ] You traced from symptom → error logs → traces → root cause
- [ ] You created an alert rule to catch this faster next time
- [ ] In Part B: You launched a formal Investigation and provided context to refine it
- [ ] You found the investigation in the Investigations list

---

**You've completed the workshop.**

Want to go further? Try:
- Triggering the next daily outage scenario and running the full investigation from scratch
- Building a dashboard from your investigation findings
- Connecting the Grafana Assistant to your team's GitHub repo via MCP and asking it to correlate recent deployments with the incident

---

**Back to:** [Lab 03 — Queries & Dashboards](./03-queries-and-dashboards.md)
