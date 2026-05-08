terraform {
  required_providers {
    genesyscloud = {
      source = "mypurecloud/genesyscloud"
      # Uncomment the 'version' line below to use specific version, otherwise we will use latest available
      # version = ">=1.63.0"
    }
  }
}

provider "genesyscloud" {
  #oauthclient_id = ""
  #oauthclient_secret = ""
  #aws_region = ""
  #sdk_debug = true
}
