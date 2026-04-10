#!/usr/bin/env bats
# =============================================================================
# Workshop Preflight — Verify the Grafana Cloud stack is ready for students
# =============================================================================
# Requires .env with: GRAFANA_WORKSHOP_URL
# Optional:           GRAFANA_SA_TOKEN (service account with Admin or Viewer role)
#
# If GRAFANA_SA_TOKEN is missing or has insufficient permissions, API tests
# will skip gracefully. The SA token needs at minimum:
#   - dashboards:read, datasources:read, folders:read, plugins:read
#
# Run: bats tests/workshop-preflight.bats
# =============================================================================

setup() {
  if [ -f .env ]; then
    set -a
    source .env
    set +a
  fi
  : "${GRAFANA_WORKSHOP_URL:?Set GRAFANA_WORKSHOP_URL in .env}"
  : "${GRAFANA_HOME_DASHBOARD_UID:=ses9sxl}"
  if [ -n "${GRAFANA_SA_TOKEN:-}" ]; then
    AUTH="Authorization: Bearer ${GRAFANA_SA_TOKEN}"
  else
    AUTH=""
  fi
}

# Helper: call Grafana API with optional auth
grafana_api() {
  local path="$1"
  if [ -n "$AUTH" ]; then
    curl -sf -H "$AUTH" "${GRAFANA_WORKSHOP_URL}${path}"
  else
    curl -sf "${GRAFANA_WORKSHOP_URL}${path}"
  fi
}

# Helper: check if token has access to an endpoint (returns true/false)
token_can_access() {
  local path="$1"
  [ -n "$AUTH" ] || return 1
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "$AUTH" "${GRAFANA_WORKSHOP_URL}${path}")
  [ "$code" = "200" ]
}

# ---------------------------------------------------------------------------
# Stack Health (no auth required)
# ---------------------------------------------------------------------------

@test "grafana stack is reachable" {
  run curl -s "${GRAFANA_WORKSHOP_URL}/api/health"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"database"'
}

@test "grafana login page loads" {
  run curl -sf -o /dev/null -w "%{http_code}" "${GRAFANA_WORKSHOP_URL}/login"
  [ "$output" = "200" ]
}

@test "assistant app URL is routable" {
  # Check the URL doesn't 404 — it may redirect to login (302) which is fine
  code=$(curl -s -o /dev/null -w "%{http_code}" "${GRAFANA_WORKSHOP_URL}/a/grafana-assistant-app")
  [ "$code" = "200" ] || [ "$code" = "302" ]
}

# ---------------------------------------------------------------------------
# Service Account Token (if provided)
# ---------------------------------------------------------------------------

@test "service account token is valid" {
  [ -n "${AUTH:-}" ] || skip "GRAFANA_SA_TOKEN not set"
  # /api/search is a low-privilege endpoint that most tokens can access
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "$AUTH" "${GRAFANA_WORKSHOP_URL}/api/search?limit=1")
  [ "$code" = "200" ]
}

# ---------------------------------------------------------------------------
# Dashboards (requires dashboards:read)
# ---------------------------------------------------------------------------

@test "home dashboard exists" {
  token_can_access "/api/dashboards/uid/${GRAFANA_HOME_DASHBOARD_UID}" || \
    skip "SA token lacks dashboards:read permission"
  run grafana_api "/api/dashboards/uid/${GRAFANA_HOME_DASHBOARD_UID}"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"uid"'
}

@test "home dashboard is set as org default" {
  token_can_access "/api/org/preferences" || \
    skip "SA token lacks org.preferences:read permission"
  run grafana_api "/api/org/preferences"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "\"homeDashboardUID\":\"${GRAFANA_HOME_DASHBOARD_UID}\""
}

# ---------------------------------------------------------------------------
# Data Sources (requires datasources:read)
# ---------------------------------------------------------------------------

@test "at least one Prometheus data source is configured" {
  token_can_access "/api/datasources" || \
    skip "SA token lacks datasources:read permission"
  run grafana_api "/api/datasources"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"type":"prometheus"'
}

@test "at least one Loki data source is configured" {
  token_can_access "/api/datasources" || \
    skip "SA token lacks datasources:read permission"
  run grafana_api "/api/datasources"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"type":"loki"'
}

@test "at least one Tempo data source is configured" {
  token_can_access "/api/datasources" || \
    skip "SA token lacks datasources:read permission"
  run grafana_api "/api/datasources"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"type":"tempo"'
}

# ---------------------------------------------------------------------------
# Assistant Plugin (requires plugins:read)
# ---------------------------------------------------------------------------

@test "grafana assistant app is installed" {
  token_can_access "/api/plugins?type=app" || \
    skip "SA token lacks plugins:read permission"
  run grafana_api "/api/plugins?type=app"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"grafana-assistant-app"'
}
