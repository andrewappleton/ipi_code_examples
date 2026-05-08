locals {
  queues = jsondecode(file("${path.module}/queues.json"))
}

resource "genesyscloud_routing_queue" "queues" {
  for_each = { for q in local.queues : q.name => q }

  name                     = each.value.name
  acw_timeout_ms           = each.value.acw_timeout_ms
  auto_answer_only         = each.value.auto_answer_only
  enable_transcription     = each.value.enable_transcription
  enable_audio_monitoring  = each.value.enable_audio_monitoring
  enable_manual_assignment = each.value.enable_manual_assignment

  media_settings_call {
    service_level_percentage = each.value.media_settings_call.service_level_percentage
    service_level_duration_ms = each.value.media_settings_call.service_level_duration_ms
    enable_auto_answer = each.value.media_settings_call.enable_auto_answer
    alerting_timeout_sec = each.value.media_settings_call.alerting_timeout_sec
  }
  # Genesys-native method to ignore queue members so that business can configure these options safely...
  ignore_members = true

  # HCL-native method to ignore certain properties so that business can configure these options safely...
  lifecycle {
    ignore_changes = [ 
        groups,
        calling_party_name
     ]
  }
}
