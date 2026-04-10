#!/usr/bin/env bats
# =============================================================================
# Workshop Content Validation — Verify lab markdown structure and links
# =============================================================================
# No .env required — runs purely against local files.
# Run: bats tests/workshop-content.bats
# =============================================================================

LABS_DIR="labs"

# ---------------------------------------------------------------------------
# All lab files exist
# ---------------------------------------------------------------------------

@test "lab 00 exists" { [ -f "${LABS_DIR}/00-getting-started.md" ]; }
@test "lab 01 exists" { [ -f "${LABS_DIR}/01-memories-infra-scan.md" ]; }
@test "lab 02 exists" { [ -f "${LABS_DIR}/02-mcp-servers.md" ]; }
@test "lab 03 exists" { [ -f "${LABS_DIR}/03-queries-and-dashboards.md" ]; }
@test "lab 04 exists" { [ -f "${LABS_DIR}/04-investigation.md" ]; }

# ---------------------------------------------------------------------------
# Inter-lab links resolve
# ---------------------------------------------------------------------------

@test "lab 00 links to lab 01" {
  grep -q '\./01-memories-infra-scan.md' "${LABS_DIR}/00-getting-started.md"
}

@test "lab 01 links to lab 02" {
  grep -q '\./02-mcp-servers.md' "${LABS_DIR}/01-memories-infra-scan.md"
}

@test "lab 02 links to lab 03" {
  grep -q '\./03-queries-and-dashboards.md' "${LABS_DIR}/02-mcp-servers.md"
}

@test "lab 03 links to lab 04" {
  grep -q '\./04-investigation.md' "${LABS_DIR}/03-queries-and-dashboards.md"
}

# ---------------------------------------------------------------------------
# Each lab has required structure
# ---------------------------------------------------------------------------

@test "every lab has a title (H1)" {
  for f in "${LABS_DIR}"/*.md; do
    head -1 "$f" | grep -q '^# '
  done
}

@test "every lab has a checkpoint section" {
  for f in "${LABS_DIR}"/*.md; do
    grep -q '## Checkpoint' "$f"
  done
}

@test "every lab has a duration estimate" {
  for f in "${LABS_DIR}"/*.md; do
    grep -q 'Duration:' "$f"
  done
}

@test "every lab has a goal statement" {
  for f in "${LABS_DIR}"/*.md; do
    grep -q 'Goal:' "$f"
  done
}

# ---------------------------------------------------------------------------
# No stale placeholders
# ---------------------------------------------------------------------------

@test "no TODO markers in labs" {
  run grep -ri 'TODO' "${LABS_DIR}"/*.md
  [ "$status" -ne 0 ]  # grep returns 1 when no match = good
}

@test "no FIXME markers in labs" {
  run grep -ri 'FIXME' "${LABS_DIR}"/*.md
  [ "$status" -ne 0 ]
}

@test "no placeholder URLs in labs" {
  run grep -E 'https?://(example\.com|your-instance|placeholder)' "${LABS_DIR}"/*.md
  [ "$status" -ne 0 ]
}

# ---------------------------------------------------------------------------
# Code blocks have content
# ---------------------------------------------------------------------------

@test "no empty code blocks in labs" {
  # Check for ``` immediately followed by ``` (empty block)
  for f in "${LABS_DIR}"/*.md; do
    run awk '/^```/{if(prev~/^```/)exit 1; prev=$0; next}{prev=$0}' "$f"
    [ "$status" -eq 0 ]
  done
}
