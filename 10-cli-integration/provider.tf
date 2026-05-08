terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
    }
    external = {
      source = "hashicorp/external"
    }
  }
}

provider "genesyscloud" {
  #oauthclient_id = ""
  #oauthclient_secret = ""
  #aws_region = ""
  #sdk_debug = true
}
