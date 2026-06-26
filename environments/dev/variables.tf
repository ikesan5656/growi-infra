variable "tenancy_ocid" {
  description = "テナンシーID"
  type        = string
  sensitive   = true // 平文表示無効
}

variable "region" {
  description = "OCIリージョン名 (例: ap-tokyo-1)"
  type        = string
}

variable "user_ocid" {
  description = "ユーザーID"
  type        = string
  sensitive   = true
}

variable "private_key" {
  description = "プライベートキー"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "フィンガープリント"
  type        = string
  sensitive   = true
}

variable "ssh_authorized_keys" {
  description = "webサーバーSSH公開鍵"
  type        = string
  sensitive   = true
}
