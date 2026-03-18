#!/usr/bin/env bash
# =============================================================================
# docker-entrypoint.sh – Entrypoint for the Azure Landing Zone container
#
# Supports the following sub-commands:
#   plan   [ENV]    terraform init + plan for ENV (default: dev)
#   apply  [ENV]    terraform init + apply for ENV
#   rover  [ENV]    generate rover standalone HTML report
#   shell           drop into an interactive bash shell
#   --help          print usage
# =============================================================================
set -euo pipefail

WORKSPACE="${WORKSPACE:-/workspace}"
TF_VERSION_CHECK=true

log()  { echo "[entrypoint] $*"; }
err()  { echo "[entrypoint] ERROR: $*" >&2; exit 1; }

usage() {
  cat <<EOF
Azure Landing Zone container

Usage: docker run azure-lz-rover:<tag> COMMAND [ENV]

Commands:
  plan   [ENV]   Run terraform plan for ENV (default: dev)
  apply  [ENV]   Run terraform apply for ENV
  rover  [ENV]   Generate rover visualisation for ENV
  shell          Start an interactive bash shell
  --help         Show this help message

ENV must match a directory under environments/ (dev | prod).

Environment variables required for Azure authentication:
  ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID
EOF
  exit 0
}

require_azure_env() {
  local missing=()
  for var in ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_SUBSCRIPTION_ID ARM_TENANT_ID; do
    [[ -z "${!var:-}" ]] && missing+=("$var")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    err "Missing required environment variables: ${missing[*]}"
  fi
}

tf_init() {
  local env="$1"
  log "terraform init (env: $env)..."
  terraform -chdir="$WORKSPACE" init \
    -input=false \
    ${TF_STATE_RG:+-backend-config="resource_group_name=${TF_STATE_RG}"} \
    ${TF_STATE_SA:+-backend-config="storage_account_name=${TF_STATE_SA}"} \
    ${TF_STATE_CONTAINER:+-backend-config="container_name=${TF_STATE_CONTAINER}"} \
    ${TF_STATE_KEY:+-backend-config="key=${TF_STATE_KEY}"} \
    -reconfigure
}

cmd="${1:-"--help"}"
env="${2:-dev}"
tfvars="$WORKSPACE/environments/${env}/terraform.tfvars"

case "$cmd" in
  plan)
    require_azure_env
    [[ -f "$tfvars" ]] || err "tfvars not found: $tfvars"
    tf_init "$env"
    log "terraform plan (env: $env)..."
    terraform -chdir="$WORKSPACE" plan \
      -var-file="$tfvars" \
      -out=/tmp/tfplan.binary \
      -input=false
    ;;

  apply)
    require_azure_env
    [[ -f "$tfvars" ]] || err "tfvars not found: $tfvars"
    tf_init "$env"
    log "terraform apply (env: $env)..."
    terraform -chdir="$WORKSPACE" apply \
      -var-file="$tfvars" \
      -auto-approve \
      -input=false
    ;;

  rover)
    require_azure_env
    [[ -f "$tfvars" ]] || err "tfvars not found: $tfvars"
    tf_init "$env"
    log "Generating plan for rover (env: $env)..."
    terraform -chdir="$WORKSPACE" plan \
      -var-file="$tfvars" \
      -out=/tmp/tfplan.binary \
      -input=false
    terraform -chdir="$WORKSPACE" show -json /tmp/tfplan.binary > /tmp/tfplan.json
    log "Running rover..."
    mkdir -p /tmp/rover-output
    rover \
      -tfJSONPlan /tmp/tfplan.json \
      -standalone true \
      -output /tmp/rover-output
    log "Rover report saved to /tmp/rover-output"
    ;;

  shell)
    log "Starting interactive shell…"
    exec bash
    ;;

  --help|-h|help)
    usage
    ;;

  *)
    err "Unknown command: $cmd. Run with --help for usage."
    ;;
esac
