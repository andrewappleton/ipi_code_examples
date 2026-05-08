# -----------------------------------------------------------------------------
# CLI Integration Example
# Uses the Genesys Cloud Platform CLI (gc) to discover existing queues,
# then imports them into Terraform state and enforces a standard ACW timeout.
# -----------------------------------------------------------------------------

# --- Data Source: Query queues from Genesys Cloud via the gc CLI -----------
# The external data source runs the helper script which returns a JSON object:
#   { "sanitised_queue_name": "queue-uuid", ... }
# This keeps everything in memory — no temporary files needed.

data "external" "queues" {
  program = ["bash", "${path.module}/fetch-queues.sh"]
}

# --- Locals: Build a usable map from the CLI output ------------------------

locals {
  # The result attribute is a map(string) of sanitised_name => queue_id
  queues = data.external.queues.result
}

# --- Import: Bring existing queues under Terraform management --------------
# Terraform 1.5+ import blocks with for_each allow bulk import without
# needing to run `terraform import` manually for each resource.

import {
  for_each = local.queues
  id       = each.value
  to       = genesyscloud_routing_queue.queue[each.key]
}

# --- Resource: Manage the queues with a standardised ACW timeout -----------

resource "genesyscloud_routing_queue" "queue" {
  for_each = local.queues

  name           = each.key
  acw_timeout_ms = 30000

  # After import, Terraform will detect drift on acw_timeout_ms and plan
  # an update to enforce the standard value (30000ms = 30 seconds).
  # All other attributes are left to be read from state on first import,
  # then managed going forward.

  lifecycle {
    # Ignore attributes we are not actively managing in this project.
    # This prevents Terraform from trying to reset values configured
    # elsewhere (e.g. via the UI or other automation).
    ignore_changes = [
      description,
      auto_answer_only,
      enable_transcription,
      enable_audio_monitoring,
      enable_manual_assignment,
      media_settings_call,
      media_settings_callback,
      media_settings_chat,
      media_settings_email,
      media_settings_message,
      calling_party_name,
      members,
      wrapup_codes,
      bullseye_rings,
      routing_rules,
      conditional_group_routing_rules,
      skill_groups,
      groups,
      teams,
      division_id,
    ]
  }
}
