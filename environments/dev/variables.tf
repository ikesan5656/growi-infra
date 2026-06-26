variable "tenancy_ocid" {
  description = "テナンシーID"
  type        = string
  sensitive   = true // 平文表示無効
}

variable "region" {
  description = "OCIリージョン名 (例: ap-tokyo-1)"
  type        = string
}
