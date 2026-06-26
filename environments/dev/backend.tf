terraform {
  required_version = ">= 1.14.0"
  required_providers {
    /*oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }*/
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }
  cloud {
    organization = "ike_innovations"
    workspaces {
      name = "growi"
    }
  }
}
