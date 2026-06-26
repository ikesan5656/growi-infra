terraform {
  # OCI Resource Managerのサポートに合わせ、1.5.x系に収まるように変更
  required_version = ">= 1.5.0, < 1.6.0"
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
