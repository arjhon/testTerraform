# =============================================================================
# Dockerfile – Azure Landing Zone deployment image
#
# Bundles Terraform + Azure CLI + rover so a single container can:
#   1. Authenticate to Azure
#   2. Run terraform plan / apply
#   3. Export the rover visualisation (standalone HTML)
#
# Build:
#   docker build -t azure-lz-rover:latest .
#
# Run (interactive):
#   docker run --rm -it \
#     -e ARM_CLIENT_ID=... \
#     -e ARM_CLIENT_SECRET=... \
#     -e ARM_SUBSCRIPTION_ID=... \
#     -e ARM_TENANT_ID=... \
#     -v $(pwd):/workspace \
#     azure-lz-rover:latest bash
# =============================================================================

# ── Stage 1: download rover binary ────────────────────────────────────────────
FROM alpine:3.19 AS rover-downloader

ARG ROVER_VERSION=0.3.3
ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN apk add --no-cache curl unzip && \
    curl -fsSL \
      "https://github.com/im2nguyen/rover/releases/download/v${ROVER_VERSION}/rover_${ROVER_VERSION}_${TARGETOS}_${TARGETARCH}.zip" \
      -o /tmp/rover.zip && \
    unzip /tmp/rover.zip -d /tmp/rover-bin && \
    chmod +x /tmp/rover-bin/rover

# ── Stage 2: final image ───────────────────────────────────────────────────────
FROM ubuntu:22.04

LABEL maintainer="platform-team" \
      description="Azure Landing Zone – Terraform + Azure CLI + rover" \
      org.opencontainers.image.source="https://github.com/arjhon/testTerraform"

ARG TERRAFORM_VERSION=1.7.0
ARG DEBIAN_FRONTEND=noninteractive

# ── System dependencies ────────────────────────────────────────────────────────
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      unzip \
      git \
      jq \
      lsb-release \
      gnupg \
      software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# ── Terraform ─────────────────────────────────────────────────────────────────
RUN curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
      -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip && \
    terraform version

# ── Azure CLI ─────────────────────────────────────────────────────────────────
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    az version

# ── rover binary ──────────────────────────────────────────────────────────────
COPY --from=rover-downloader /tmp/rover-bin/rover /usr/local/bin/rover

# ── Working directory ─────────────────────────────────────────────────────────
WORKDIR /workspace

COPY . /workspace/

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["--help"]
