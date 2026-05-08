# JSON to Queue Example

This example demonstrates using a **JSON file** as an external data source to drive Terraform resource creation. JSON is the right choice when the data structure becomes nested or hierarchical — something CSV cannot cleanly represent.

## Why JSON?

- **Nested structures** — queue configuration includes sub-objects like `media_settings_call` with their own set of properties. JSON handles this naturally.
- **Native HCL compatibility** — `jsondecode()` maps JSON directly to Terraform objects with correct types (numbers, booleans, nested maps) without manual conversion.
- **1:1 attribute mapping** — the JSON structure mirrors the Terraform resource schema, making it immediately clear how data maps to configuration.

## What It Does

1. Reads `queues.json` using Terraform's built-in `jsondecode()` function
2. Builds a map keyed by queue name for use with `for_each`
3. Creates `genesyscloud_routing_queue` resources with all properties — including nested `media_settings_call` — sourced directly from the JSON

## Project Structure

```
05-json-to-queue/
├── provider.tf    # Genesys Cloud provider configuration
├── queues.json    # External data source (structured queue definitions)
├── json.tf        # HCL logic: jsondecode → for_each → resource
└── README.md
```

## How It Works

```hcl
locals {
  queues = jsondecode(file("${path.module}/queues.json"))
}

resource "genesyscloud_routing_queue" "queues" {
  for_each       = { for q in local.queues : q.name => q }
  name           = each.value.name
  acw_timeout_ms = each.value.acw_timeout_ms

  media_settings_call {
    service_level_percentage  = each.value.media_settings_call.service_level_percentage
    service_level_duration_ms = each.value.media_settings_call.service_level_duration_ms
    enable_auto_answer        = each.value.media_settings_call.enable_auto_answer
    alerting_timeout_sec      = each.value.media_settings_call.alerting_timeout_sec
  }
}
```

Because `jsondecode()` preserves types, there is no need for `tonumber()` or string comparison — booleans are booleans, numbers are numbers, and nested objects are accessed with dot notation.

## JSON Format

```json
[
  {
    "name": "billing",
    "acw_timeout_ms": 30000,
    "auto_answer_only": true,
    "enable_transcription": true,
    "enable_audio_monitoring": false,
    "enable_manual_assignment": false,
    "media_settings_call": {
      "service_level_percentage": 0.01,
      "service_level_duration_ms": 1002,
      "enable_auto_answer": true,
      "alerting_timeout_sec": 10
    }
  }
]
```

Each object in the array represents a queue. The `media_settings_call` sub-object maps directly to the nested block in the Terraform resource.

## Additional Patterns Demonstrated

This example also shows two approaches to protecting business-managed attributes:

- **`ignore_members = true`** — a Genesys Cloud provider-native option that prevents Terraform from managing queue membership
- **`lifecycle { ignore_changes = [...] }`** — the standard HCL mechanism to exclude specific attributes from drift detection

These patterns allow Terraform to own the structural configuration while leaving operational settings (members, groups, calling party name) under business control.

## Trade-offs

| Strength | Limitation |
|----------|-----------|
| Supports nested and complex structures | Slightly harder for non-technical users to edit by hand |
| Types are preserved — no conversion needed | Larger diffs in source control for wide objects |
| Maps directly to Terraform resource schema | Requires valid JSON syntax (trailing commas, quoting) |

## When to Choose JSON over CSV

Use JSON when:
- Your resource has **nested blocks** (e.g. `media_settings_call`, `bullseye_rings`)
- You need **typed values** without manual conversion
- The data structure may **evolve** to include arrays or optional sub-objects

Stick with CSV when:
- The data is **flat** (all scalar values, no nesting)
- The audience is **non-technical** and prefers spreadsheet editing

## Usage

```bash
terraform init
terraform plan
terraform apply
```

To add a new queue, append an object to the array in `queues.json` and re-run `terraform apply`.
