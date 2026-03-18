#!/usr/bin/env bash
# =============================================================================
# rover.sh – Visualise the Terraform plan / state using rover
#
# Rover (https://github.com/im2nguyen/rover) generates an interactive diagram
# of your Terraform resources so you can explore dependencies, see drift and
# understand what will change before you apply.
#
# Usage:
#   ./rover.sh [OPTIONS]
#
# Options:
#   -e, --env        Target environment directory (default: environments/dev)
#   -p, --plan-file  Path to an existing plan file (skips terraform plan)
#   -w, --web-port   Port to serve the rover UI on (default: 9000)
#   -h, --help       Show this help message
#
# Requirements:
#   - Docker (https://docs.docker.com/get-docker/)
#   - Terraform >= 1.3 (https://www.terraform.io/downloads)
#   - Azure credentials configured (ARM_* env vars or az login)
# =============================================================================

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────────────────────
ENV_DIR="environments/dev"
PLAN_FILE=""
WEB_PORT="9000"
ROVER_IMAGE="im2nguyen/rover:latest"
PLAN_OUT="/tmp/tfplan.binary"
PLAN_JSON="/tmp/tfplan.json"

# ── Helpers ───────────────────────────────────────────────────────────────────
usage() {
  sed -n '/^# Usage:/,/^# =====/p' "$0" | sed 's/^# \?//'
  exit 0
}

log()  { echo "[rover] $*"; }
err()  { echo "[rover] ERROR: $*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "'$1' is required but not found in PATH."
}

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)        ENV_DIR="$2"; shift 2 ;;
    -p|--plan-file)  PLAN_FILE="$2"; shift 2 ;;
    -w|--web-port)   WEB_PORT="$2"; shift 2 ;;
    -h|--help)       usage ;;
    *) err "Unknown option: $1. Use -h for help." ;;
  esac
done

# ── Pre-flight checks ─────────────────────────────────────────────────────────
require_cmd docker
require_cmd terraform

[[ -d "$ENV_DIR" ]] || err "Environment directory not found: $ENV_DIR"

TFVARS_FILE="$ENV_DIR/terraform.tfvars"
[[ -f "$TFVARS_FILE" ]] || err "tfvars file not found: $TFVARS_FILE"

# ── Step 1: terraform init (if needed) ────────────────────────────────────────
if [[ ! -d ".terraform" ]]; then
  log "Running terraform init…"
  terraform init -input=false
fi

# ── Step 2: Generate / use plan file ─────────────────────────────────────────
if [[ -n "$PLAN_FILE" ]]; then
  [[ -f "$PLAN_FILE" ]] || err "Plan file not found: $PLAN_FILE"
  log "Using existing plan file: $PLAN_FILE"
  PLAN_OUT="$PLAN_FILE"
else
  log "Running terraform plan → $PLAN_OUT"
  terraform plan \
    -var-file="$TFVARS_FILE" \
    -out="$PLAN_OUT" \
    -input=false
fi

# ── Step 3: Convert plan to JSON (rover needs JSON) ────────────────────────────
log "Converting plan to JSON → $PLAN_JSON"
terraform show -json "$PLAN_OUT" > "$PLAN_JSON"

# ── Step 4: Launch rover ──────────────────────────────────────────────────────
log "Starting rover UI on http://localhost:${WEB_PORT} …"
log "Press Ctrl+C to stop."

docker run --rm \
  -p "${WEB_PORT}:9000" \
  -v "$(pwd):/src" \
  -v "${PLAN_JSON}:/rover/plan.json" \
  -e "PLAN_JSON=/rover/plan.json" \
  "$ROVER_IMAGE"
