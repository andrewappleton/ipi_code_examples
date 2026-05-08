# CSV to Queue Example

This example demonstrates using a **CSV file** as an external data source to drive Terraform resource creation. CSV is a natural fit when the data structure is flat — each row maps directly to a queue with simple key/value attributes.

## Why CSV?

- **Familiar format** — business stakeholders can author and maintain queue definitions in Excel or Google Sheets and export to CSV without needing to understand HCL or JSON.
- **Flat data, flat file** — when every queue has the same set of scalar properties (no nesting), CSV keeps things readable and diff-friendly in version control.
- **Low barrier to entry** — no special tooling required to edit; any text editor or spreadsheet application will do.

## What It Does

1. Reads `queues.csv` using Terraform's built-in `csvdecode()` function
2. Builds a map keyed by queue name for use with `for_each`
3. Creates `genesyscloud_routing_queue` resources with a configurable name prefix/suffix and all properties sourced from the CSV columns

## Project Structure

```
00-csv-to-queue/
├── provider.tf    # Genesys Cloud provider configuration
├── queues.csv     # External data source (the business-owned input)
├── queues.tf      # HCL logic: csvdecode → for_each → resource
└── README.md
```

## How It Works

```hcl
locals {
  queue_rows = csvdecode(file("${path.module}/queues.csv"))
  queues_by_name = { for queue in local.queue_rows : queue.name => queue }
}

resource "genesyscloud_routing_queue" "queue" {
  for_each       = local.queues_by_name
  name           = "${local.prefix}-${each.value.name}-${local.suffix}"
  acw_timeout_ms = tonumber(each.value.acw_timeout_ms)
  ...
}
```

The CSV columns map 1:1 to resource attributes. Because `csvdecode()` returns all values as strings, numeric fields are wrapped with `tonumber()` and booleans are compared with `lower() == "true"`.

## CSV Format

| Column | Type | Description |
|--------|------|-------------|
| `name` | string | Queue name (used as the map key) |
| `acw_timeout_ms` | number | After-call work timeout in milliseconds |
| `auto_answer_only` | bool | Whether the queue only accepts auto-answered interactions |
| `enable_transcription` | bool | Enable real-time transcription |
| `enable_audio_monitoring` | bool | Enable supervisor audio monitoring |
| `enable_manual_assignment` | bool | Allow manual assignment of interactions |
| `media_settings_queue__service_level_percentage` | number | SLA target percentage |
| `media_settings_queue__service_level_duration_ms` | number | SLA target duration in ms |

## Trade-offs

| Strength | Limitation |
|----------|-----------|
| Easy for non-technical users to edit | Cannot represent nested or repeated structures |
| Clean diffs in source control | All values are strings — requires type conversion in HCL |
| Minimal boilerplate | Column naming conventions needed for nested attributes (e.g. double-underscore) |

## Usage

```bash
terraform init
terraform plan
terraform apply
```

To add a new queue, simply append a row to `queues.csv` and re-run `terraform apply`.
