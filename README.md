# Azure Landing Zone – Terraform

A production-ready [Azure Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/) built with verified Terraform modules, following the [Microsoft Cloud Adoption Framework (CAF)](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/).  The repository also ships with built-in support for **[rover](https://github.com/im2nguyen/rover)** – an interactive Terraform visualiser.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Modules](#modules)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Rover – Terraform Visualiser](#rover--terraform-visualiser)
- [Environment Configuration](#environment-configuration)
- [Contributing](#contributing)

---

## Architecture Overview

```
Tenant Root Group
└── Landing Zone (root management group)
    ├── Platform         ← shared services
    ├── Workloads        ← application workloads
    ├── Sandbox          ← experimentation
    └── Decommissioned   ← resources being retired (prod only)
```

The landing zone provisions five capability areas:

| Capability | Module | Key Resources |
|---|---|---|
| **Management Groups** | `management_groups` | Azure Management Group hierarchy |
| **Networking** | `networking` | Hub VNet, spoke VNets, VNet Peerings, Azure Firewall, VPN Gateway |
| **Identity** | `identity` | Azure Key Vault, RBAC role assignments |
| **Policy** | `policy` | Azure Policy initiative assignments |
| **Monitoring** | `monitoring` | Log Analytics Workspace, Microsoft Defender for Cloud |

---

## Repository Structure

```
.
├── main.tf                     # Root module – wires up all child modules
├── variables.tf                # All input variables with validation & defaults
├── outputs.tf                  # Key outputs (VNet IDs, KV URI, etc.)
├── versions.tf                 # Provider version constraints
├── rover.sh                    # Convenience script to launch rover
├── docker-compose.yml          # docker compose services for rover & Terraform
├── environments/
│   ├── dev/
│   │   └── terraform.tfvars   # Dev environment variable values
│   └── prod/
│       └── terraform.tfvars   # Prod environment variable values
└── modules/
    ├── management_groups/      # Azure Management Group hierarchy
    ├── networking/             # Hub-spoke network topology
    ├── identity/               # Key Vault & RBAC
    ├── policy/                 # Azure Policy assignments
    └── monitoring/             # Log Analytics & Defender for Cloud
```

---

## Modules

### `management_groups`

Creates a root management group and an arbitrary number of child groups beneath it.

| Input | Description | Required |
|---|---|---|
| `root_management_group_id` | Name/ID for the root group | ✅ |
| `root_management_group_name` | Display name for the root group | ✅ |
| `management_groups` | Map of child management groups | ❌ |

### `networking`

Deploys a hub-and-spoke network topology.

| Input | Description | Default |
|---|---|---|
| `hub_vnet_cidr` | Address space for the hub VNet | `10.0.0.0/16` |
| `hub_subnets` | Subnet map for the hub | See `variables.tf` |
| `spoke_vnets` | Spoke VNet definitions | `{}` |
| `enable_firewall` | Deploy Azure Firewall | `false` |
| `enable_vpn_gateway` | Deploy VPN Gateway | `false` |

### `identity`

Provisions an Azure Key Vault and RBAC assignments.

| Input | Description | Required |
|---|---|---|
| `key_vault_name` | Key Vault name | ✅ |
| `tenant_id` | Azure AD tenant ID | ✅ |
| `admin_group_object_ids` | Groups to assign Owner | ❌ |
| `reader_group_object_ids` | Groups to assign Reader | ❌ |

### `policy`

Assigns Azure Policy initiatives to a management group.

| Input | Description | Required |
|---|---|---|
| `management_group_id` | Target management group | ✅ |
| `policy_assignments` | Map of initiative assignments | ❌ |

### `monitoring`

Creates a Log Analytics Workspace and enables Microsoft Defender for Cloud.

| Input | Description | Default |
|---|---|---|
| `log_analytics_workspace.name` | Workspace name | `law-landingzone` |
| `log_analytics_workspace.retention_in_days` | Data retention | `90` |
| `security_center_contact` | Defender contact info | `null` |

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | ≥ 1.3 | `brew install terraform` |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | latest | `brew install azure-cli` |
| [Docker](https://docs.docker.com/get-docker/) _(rover only)_ | latest | See Docker docs |

Authenticate to Azure before running Terraform:

```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/arjhon/testTerraform.git
cd testTerraform

# 2. Copy and customise the dev variables
cp environments/dev/terraform.tfvars my.tfvars
#    → Edit my.tfvars and fill in tenant_id, etc.

# 3. Initialise Terraform
terraform init

# 4. Preview the changes
terraform plan -var-file=my.tfvars

# 5. Apply
terraform apply -var-file=my.tfvars
```

### Using environment directories

```bash
# Dev
terraform plan  -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# Prod
terraform plan  -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```

---

## Rover – Terraform Visualiser

[Rover](https://github.com/im2nguyen/rover) renders an **interactive diagram** of your Terraform plan so you can explore resource relationships, spot configuration drift, and understand the blast radius of a change – all before running `apply`.

### Option A – convenience shell script

```bash
# Dev environment (default)
./rover.sh

# Prod environment, custom port
./rover.sh --env environments/prod --web-port 9001

# Reuse an existing plan file (skips terraform plan)
./rover.sh --plan-file /tmp/my-plan.binary
```

Open **http://localhost:9000** in your browser once rover starts.

### Option B – docker compose

```bash
# 1. Generate a JSON plan
terraform plan -var-file=environments/dev/terraform.tfvars -out=/tmp/tfplan.binary
terraform show -json /tmp/tfplan.binary > /tmp/tfplan.json

# 2. Start rover
PLAN_JSON=/tmp/tfplan.json docker compose up rover
```

### Option C – docker run (manual)

```bash
terraform plan -var-file=environments/dev/terraform.tfvars -out=/tmp/tfplan.binary
terraform show -json /tmp/tfplan.binary > /tmp/tfplan.json

docker run --rm \
  -p 9000:9000 \
  -v /tmp/tfplan.json:/rover/plan.json \
  -e PLAN_JSON=/rover/plan.json \
  im2nguyen/rover:latest
```

---

## Environment Configuration

| Variable | Dev default | Prod default |
|---|---|---|
| `environment` | `dev` | `prod` |
| `enable_firewall` | `false` | `true` |
| `enable_vpn_gateway` | `false` | `true` |
| `log_analytics_workspace.retention_in_days` | `30` | `90` |
| `security_center_contact` | `null` | configured |

All configurable inputs are documented in [`variables.tf`](./variables.tf).

---

## Contributing

1. Fork the repository and create a feature branch.
2. Make changes following the existing module structure.
3. Run `terraform fmt -recursive` before committing.
4. Open a pull request describing your changes.

> **Tip:** Use `./rover.sh` to generate a visual diagram of your changes before submitting a PR.