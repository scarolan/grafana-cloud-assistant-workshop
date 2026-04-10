#!/usr/bin/env bash
# =============================================================================
# Workshop QA — AI-powered preflight check using Claude Code + Chrome
# =============================================================================
# Run the day before a workshop delivery to verify the full student experience.
# Uses Claude Code with the Chrome extension to walk through every lab,
# test actual Assistant interactions, and report any issues.
#
# Prerequisites:
#   - Claude Code CLI installed (claude)
#   - Claude in Chrome extension running
#   - Chrome open and logged into the workshop Grafana instance
#   - .env file with GRAFANA_WORKSHOP_URL and GRAFANA_STUDENT_USER
#
# Usage:
#   ./scripts/workshop-qa.sh                  # full QA run
#   ./scripts/workshop-qa.sh --quick          # fast check (API only, no browser)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source .env for URLs
if [ -f "$REPO_DIR/.env" ]; then
  set -a
  source "$REPO_DIR/.env"
  set +a
fi

: "${GRAFANA_WORKSHOP_URL:?Set GRAFANA_WORKSHOP_URL in .env}"

# ---------------------------------------------------------------------------
# Quick mode: just run BATS tests (no browser)
# ---------------------------------------------------------------------------
if [ "${1:-}" = "--quick" ]; then
  echo "=== Quick preflight (API + content checks only) ==="
  echo ""
  echo "--- Content validation ---"
  bats "$REPO_DIR/tests/workshop-content.bats"
  echo ""
  echo "--- Stack health ---"
  bats "$REPO_DIR/tests/workshop-preflight.bats"
  echo ""
  echo "--- Data quality ---"
  bats "$REPO_DIR/tests/workshop-data.bats"
  echo ""
  echo "=== Quick preflight complete ==="
  exit 0
fi

# ---------------------------------------------------------------------------
# Full QA: Claude Code walks through the labs with Chrome
# ---------------------------------------------------------------------------
echo "=== Full Workshop QA (Claude Code + Chrome) ==="
echo ""
echo "This will take 10-15 minutes. Claude Code will:"
echo "  1. Open the Grafana instance in Chrome"
echo "  2. Walk through each lab as a student"
echo "  3. Test actual Assistant queries"
echo "  4. Report any issues found"
echo ""
echo "Make sure:"
echo "  - Chrome is open"
echo "  - Claude in Chrome extension is active"
echo "  - You are logged into ${GRAFANA_WORKSHOP_URL}"
echo ""
read -p "Ready? Press Enter to start..."

# Build the QA prompt
QA_PROMPT=$(cat <<'PROMPT'
You are doing a preflight QA check of a Grafana Assistant workshop. The labs are in the labs/ directory. The Grafana instance is already open in Chrome and logged in.

Walk through the following checks and report a pass/fail for each:

## Lab 00: Getting Started
1. Navigate to the Assistant page. Verify the main page loads with the input box, gear icon, and three buttons (Previous investigations, Integration hub, Skills).
2. Type "Hello" and press Enter. Verify a response appears in the right panel.
3. Verify follow-up suggestion chips appear below the response.

## Lab 01: Memories & Infra Scan
4. Click the gear icon in the input box. Verify the dropdown shows "Rules", "MCP servers", "Settings".
5. Click Settings → verify the Settings page loads with "Assistant behavior" sidebar.
6. Click "Assistant memories" → verify the "Start Discovery Scan" button is visible.
7. Go back and click "Assistant behavior" → verify existing Custom Rules are shown with Edit/Delete buttons.

## Lab 02: MCP Servers
8. Navigate to Settings → Integrations. Verify the "MCP servers" page loads.
9. Verify the Kubernetes MCP server shows "healthy" status with tools enabled.
10. Verify the Quick setup section shows popular servers (GitHub, Cloudflare, PagerDuty).

## Lab 03: Queries & Dashboards (CRITICAL — test actual queries)
11. Start a new conversation. Type: "Show me error and critical logs from the last 6 hours"
    - Wait for the full response. PASS if it returns actual log entries or a meaningful explanation of what it found. FAIL if it errors out or returns nothing useful.
12. Start a new conversation. Type: "Which service has the highest P95 latency right now?"
    - Wait for the full response. PASS if it returns results with an inline chart. Note what latency values it reports. FAIL if no data or no chart.
13. Start a new conversation. Type: "Which services have the highest error rates right now?"
    - Wait for the full response. PASS if it returns a chart and identifies services. FAIL if empty.

## Lab 04: Investigation
14. On the main page, verify the "Start investigation" button exists in the Recent investigations section.
15. Click it. Verify the page switches to "Assistant Investigations" mode with a "Deep Investigation" chip in the input.
16. Press back/navigate to the main page. Click "Previous investigations". Verify the investigations list loads with filter tabs (All, Completed, In Progress, etc.)

## Summary
After all checks, provide a summary table:

| Check | Status | Notes |
|-------|--------|-------|
| 1     | PASS/FAIL | ... |
| ...   | ...    | ... |

Flag any FAIL items with specific details about what went wrong and whether the lab text needs updating.
PROMPT
)

# Run Claude Code with the Chrome flag
cd "$REPO_DIR"
claude --chrome -p "$QA_PROMPT"
