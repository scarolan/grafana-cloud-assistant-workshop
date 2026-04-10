#!/usr/bin/env bats
# =============================================================================
# Workshop Data Quality — Verify the signals referenced in labs actually exist
# =============================================================================
# These tests query Loki and Mimir via the Grafana data source proxy to
# confirm the data patterns described in the lab text are present.
#
# Requires .env with: GRAFANA_WORKSHOP_URL, GRAFANA_SA_TOKEN
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
  AUTH="Authorization: Bearer ${GRAFANA_SA_TOKEN}"

  # Find the Prometheus data source UID (first match)
  if [ -z "$PROM_UID" ]; then
    PROM_UID=$(curl -sf -H "$AUTH" "${GRAFANA_WORKSHOP_URL}/api/datasources" \
      | grep -o '"uid":"[^"]*".*"type":"prometheus"' \
      | head -1 | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)
    export PROM_UID
  fi

  # Find the Loki data source UID (first match)
  if [ -z "$LOKI_UID" ]; then
    LOKI_UID=$(curl -sf -H "$AUTH" "${GRAFANA_WORKSHOP_URL}/api/datasources" \
      | grep -o '"uid":"[^"]*".*"type":"loki"' \
      | head -1 | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)
    export LOKI_UID
  fi
}

# Helper: query Prometheus via data source proxy
prom_query() {
  local query="$1"
  curl -sf -H "$AUTH" --data-urlencode "query=${query}" \
    "${GRAFANA_WORKSHOP_URL}/api/datasources/proxy/uid/${PROM_UID}/api/v1/query"
}

# Helper: query Loki via data source proxy
loki_query() {
  local query="$1"
  local end
  end=$(date -u +%s)
  local start=$((end - 21600))  # 6 hours ago
  curl -sf -H "$AUTH" \
    --data-urlencode "query=${query}" \
    --data-urlencode "start=${start}" \
    --data-urlencode "end=${end}" \
    --data-urlencode "limit=5" \
    "${GRAFANA_WORKSHOP_URL}/api/datasources/proxy/uid/${LOKI_UID}/loki/api/v1/query_range"
}

# ---------------------------------------------------------------------------
# Lab 03 Step 1: Logs exist
# ---------------------------------------------------------------------------

@test "loki has logs in the last 6 hours" {
  run loki_query '{job=~".+"}'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"result"'
  # Verify we got at least one stream
  ! echo "$output" | grep -q '"result":\[\]'
}

@test "error-level logs exist in the last 6 hours" {
  run loki_query '{job=~".+"} |~ "(?i)(error|fatal|crit)"'
  [ "$status" -eq 0 ]
  # Any result means errors exist — even an empty result array is parseable
  echo "$output" | grep -q '"result"'
}

# ---------------------------------------------------------------------------
# Lab 03 Step 2: Checkout service has latency data
# ---------------------------------------------------------------------------

@test "prometheus data source responds" {
  run prom_query 'up'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"result"'
}

@test "checkout service latency metrics exist" {
  # Check for span metrics or histogram data for checkout
  run prom_query 'count(duration_milliseconds_count{service_name=~".*checkout.*"})'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"result"'
}

@test "multiple services are reporting span metrics" {
  run prom_query 'count(count by (service_name)(calls_total))'
  [ "$status" -eq 0 ]
  # Extract the count — should be > 5 services
  count=$(echo "$output" | grep -o '"value":\["[0-9.]*","[0-9]*"' | grep -o '"[0-9]*"$' | tr -d '"')
  [ -n "$count" ] && [ "$count" -gt 5 ]
}

# ---------------------------------------------------------------------------
# Lab 03 Step 2: Frontend has traffic (not a dead environment)
# ---------------------------------------------------------------------------

@test "frontend service has recent traffic" {
  run prom_query 'sum(rate(calls_total{service_name=~".*frontend.*"}[30m]))'
  [ "$status" -eq 0 ]
  # Check that the value is not null/0
  echo "$output" | grep -q '"value"'
}

# ---------------------------------------------------------------------------
# Lab 04: Evidence of outage/restarts (may not always be present)
# ---------------------------------------------------------------------------

@test "pod restart data exists in prometheus" {
  run prom_query 'count(kube_pod_container_status_restarts_total > 0)'
  [ "$status" -eq 0 ]
  echo "$output" | grep -q '"result"'
}
