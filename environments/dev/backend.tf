terraform {
  required_version = ">= 1.14.0"
  required_providers {
    # OCIスタックとして作成
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0"
    }
    /*random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }*/
  }
}
