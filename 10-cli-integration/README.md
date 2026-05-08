# CLI Integration Example

This example demonstrates how to use the **Genesys Cloud Platform CLI (`gc`)** as a data source within Terraform to discover existing resources, import them into state, and enforce standardised configuration.

## What It Does

1. **Queries** all routing queues from Genesys Cloud using `gc routing queues list`
2. **Imports** them into Terraform state using HCL `import {}` blocks (Terraform 1.5+)
3. **Enforces** a standard `acw_timeout_ms` of 30000ms (30 seconds) across all queues

## How It Works

```
┌─────────────────────┐       ┌──────────────────┐       ┌─────────────────────┐
│  external data src  │──────▶│  fetch-queues.sh │──────▶│  gc CLI (API call)  │
└─────────────────────┘       └──────────────────┘       └─────────────────────┘
         │                              │
         │  returns JSON map:           │  returns CSV:
         │  { "name": "id", ... }       │  QueueName,UUID
         ▼                              ▼
┌─────────────────────┐
│  import {} blocks   │  ◀── for_each over the map
│  + resource block   │  ◀── sets acw_timeout_ms = 30000
└─────────────────────┘
```

### Key Design Decisions

- **In-memory only** — no temporary files are written; the CLI output is piped through `awk` and returned as JSON directly to Terraform.
- **Queue names are sanitised** — spaces, hyphens, and special characters are replaced with underscores to produce valid Terraform resource addresses.
- **Selective management** — only `acw_timeout_ms` is actively enforced; all other attributes use `ignore_changes` so that business-configured values (members, skills, etc.) are not overwritten.

## Prerequisites

- Terraform >= 1.5
- Genesys Cloud CLI (`gc`) installed and authenticated (`gc profiles` / environment variables)
- The `mypurecloud/genesyscloud` Terraform provider

## Usage

```bash
# Authenticate the gc CLI (if not already done)
gc profiles new --name myorg --environment mypurecloud.com

# Initialise and plan
terraform init
terraform plan

# On first run, Terraform will import all discovered queues and show
# any drift on acw_timeout_ms. Apply to enforce the standard value.
terraform apply
```

## Customisation

- Change the target `acw_timeout_ms` value in `queues.tf`
- Add or remove attributes from the `ignore_changes` list to control what Terraform manages
- Modify `fetch-queues.sh` to filter queues (e.g. by name prefix) before returning them
