locals {
  queue_rows = csvdecode(file("${path.module}/queues.csv"))
  prefix = "IPI"
  suffix = "Q"
  queues_by_name = {
    for queue in local.queue_rows :
    queue.name => queue
  }
}

data "genesyscloud_auth_division_home" "home" {
  name = "Home"
}

resource "genesyscloud_routing_queue" "queue" {
  for_each = local.queues_by_name

  name                     = "${local.prefix}-${each.value.name}-${local.suffix}"
  acw_timeout_ms           = tonumber(each.value.acw_timeout_ms)
  auto_answer_only         = lower(each.value.auto_answer_only) == "true"
  enable_transcription     = lower(each.value.enable_transcription) == "true"
  enable_audio_monitoring  = lower(each.value.enable_audio_monitoring) == "true"
  enable_manual_assignment = lower(each.value.enable_manual_assignment) == "true"
  media_settings_call {
    service_level_percentage = tonumber(each.value.media_settings_queue__service_level_percentage)
    service_level_duration_ms = tonumber(each.value.media_settings_queue__service_level_duration_ms)
    enable_auto_answer = true
    alerting_timeout_sec = 10
  }
  division_id              = data.genesyscloud_auth_division_home.home.id
}