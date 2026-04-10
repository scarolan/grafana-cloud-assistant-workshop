#!/usr/bin/env bats
# =============================================================================
# Workshop Data Quality — Verify the signals referenced in labs actually exist
# =============================================================================
# Queries Loki and Mimir via the Grafana data source proxy to confirm the
# data patterns described in lab text are present.
#
# Requires .env with: GRAFANA_WORKSHOP_URL, GRAFANA_SA_TOKEN
# Optional:           GRAFANA_PROM_UID (default: grafanacloud-prom)
#                     GRAFANA_LOKI_UID (default: grafanacloud-logs)
#
# Run: bats tests/workshop-data.bats
# =============================================================================

setup() {
  if [ -f .env ]; then
    set -a
    source .env
    set +a
  fi
  : "${GRAFANA_WORKSHOP_URL:?Set GRAFANA_WORKSHOP_URL in .env}"
  : "${GRAFANA_SA_TOKEN:?Set GRAFANA_SA_TOKEN in .env}"
  : "${GRAFANA_PROM_UID:=grafanacloud-prom}"
  : "${GRAFANA_LOKI_UID:=grafanacloud-logs}"
  AUTH="Authorization: Bearer ${GRAFANA_SA_TOKEN}"
}

# Helper: query Prometheus via data source proxy
prom_query() {
  local query="$1"
  curl -s -H "$AUTH" --data-urlencode "query=${query}" \
    "${GRAFANA_WORKSHOP_URL}/api/datasources/proxy/uid/${GRAFANA_PROM_UID}/api/v1/query"
}

# Helper: query Loki via data source proxy
loki_query() {
  local query="$1"
  local end
  end=$(date -u +%s)
  local start=$((end - 21600))  # 6 hours ago
  curl -s -H "$AUTH" \
    --data-urlencode "query=${query}" \
    --data-urlencode "start=${start}" \
    --data-urlencode "end=${end}" \
    --data-urlencode "limit=5" \
    "${GRAFANA_WORKSHOP_URL}/api/datasources/proxy/uid/${GRAFANA_LOKI_UID}/loki/api/v1/query_range"
}

# ---------------------------------------------------------------------------
# Lab 03 Step 1: Logs exist
# ---------------------------------------------------------------------------

@test "loki has logs in the last 6 hours" {
  run loki_query '{job=~".+"}'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
  # Verify we got at least one stream (not an empty result)
  ! echo "$output" | grep -q '"result":\[\]'
}

@test "error-level logs exist in the last 6 hours" {
  run loki_query '{job=~".+"} |~ "(?i)(error|fatal|crit)"'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
}

# ---------------------------------------------------------------------------
# Lab 03 Step 2: Prometheus has service metrics
# ---------------------------------------------------------------------------

@test "prometheus data source responds" {
  run prom_query 'up'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
}

@test "service metrics exist (checkout orders)" {
  run prom_query 'count(checkout_orders_total)'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
  echo "$output" | grep -q '"value"'
}

@test "checkout service DB latency metrics exist" {
  run prom_query 'count(db_sql_latency_milliseconds_count)'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
  echo "$output" | grep -q '"value"'
}

# ---------------------------------------------------------------------------
# Lab 03 Step 2: Environment has active traffic
# ---------------------------------------------------------------------------

@test "environment has active traffic (frontend sessions)" {
  run prom_query 'sum(rate(app_frontend_sessions_created_total[1h]))'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
  echo "$output" | grep -q '"value"'
}

# ---------------------------------------------------------------------------
# Lab 04: Pod restarts exist
# ---------------------------------------------------------------------------

@test "pod restart data exists in prometheus" {
  run prom_query 'count(kube_pod_container_status_restarts_total > 0)'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"status":"success"'
}
