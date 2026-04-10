# Lab 00: Getting Started

**Duration:** ~15 minutes  
**Goal:** Log into the shared Grafana stack, orient yourself to the environment, and create your personal folder so you don't collide with other workshop participants.

---

## What You're Working With

This workshop uses **appenv** — a realistic e-commerce application (a telescope shop) that ships metrics, logs, and traces to a shared Grafana Cloud stack. You'll use Grafana Assistant to explore and investigate this data throughout the workshop.

The application has dozens of microservices: a frontend, checkout, cart, payment, product catalog, and more. It generates real traffic continuously, and experiences a **scheduled daily outage** that we'll investigate in the final lab.

You do **not** need to run or configure anything. The data is already flowing.

---

## Step 1: Log In

1. Open your browser and navigate to the workshop Grafana instance:

   ```
   https://caeb48.grafana.net/
   ```

2. Use the lab credentials provided by your instructor (also sent via email).

3. You should land on the **System Overview** dashboard inside the **Field Eng Otel Environment** folder. If you see graphs and panels loading, you're in.

---

## Step 2: Create Your Personal Folder

Since everyone shares the same Grafana stack, you'll save your work to a personal folder.

1. In the left sidebar, click **Dashboards**.

2. Click **New** (top right) → **New folder**.

3. Name it with your first name or initials — for example: `Sean` or `SC`.

4. Click **Create**.

Keep this folder name in mind — you'll use it when saving dashboards in Lab 03.

---

## Step 3: Orient Yourself to the Environment

1. In the left sidebar, click **Dashboards** and look through the folder list. You'll see a **Field Eng Otel Environment** folder with pre-built dashboards for the telescope shop.

2. Open the **System Overview** dashboard. This shows the health of the microservices at a glance — request rates, error rates, latency.

3. Browse a few more dashboards to get a feel for what's available. Don't worry about understanding every panel yet.

---

## Step 4: Find Grafana Assistant

Grafana Assistant lives in the left sidebar as its own section.

1. In the left sidebar, click **Assistant**. This opens the full Assistant page.

2. You'll see:
   - A large text input in the center — the `@` symbol in the top-left corner opens a data source context picker; the gear icon (⚙) in the top-right opens a quick-access menu for **Rules**, **MCP servers**, and **Settings**
   - Three buttons below the input: **Previous investigations**, **Integration hub**, **Skills**
   - A persistent conversation panel on the right side of the screen showing suggested prompts
   - A **Start investigation** button in the "Recent investigations" section on the main page

3. Click in the text input and type:

   ```
   Hello
   ```

   Press **Enter**. The right-hand conversation panel (always visible) switches from showing suggested prompts to showing your active conversation. The main Assistant page stays visible on the left.

4. Notice what appears in the response panel:
   - **Your message** in a dark rounded bubble at the top
   - Assistant's **response** appears below — for a simple greeting it answers directly. For queries that search your data, you'll also see **reasoning steps** showing what it queried and found.
   - **Follow-up suggestion chips** at the bottom labeled "Follow-up" — click any one to continue the conversation without typing

> **Tip:** The `@` symbol in the input opens a **data source context picker** — attach a specific Loki, Prometheus, or Tempo data source to focus Assistant's answers on that source. Type `/` to open slash commands. You'll use both in later labs. The gear icon (⚙) is a quick-access shortcut to Rules, MCP server config, and Settings.

---

## Checkpoint

Before moving on, confirm:

- [ ] You can log in to the workshop Grafana instance
- [ ] You've created a personal folder with your name/initials
- [ ] You can see the pre-loaded dashboards with live telescope shop data
- [ ] Grafana Assistant opens and responds to a message

---

**Next:** [Lab 01 — Memories & Infra Scan](./01-memories-infra-scan.md)
