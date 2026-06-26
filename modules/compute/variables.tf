variable "compartment_id" {
  description = "コンパートメントID"
  type        = string
}

variable "compute_settings" {
  type = object({
    name                = string
    availability_domain = string
    subnet_id           = string
    nsg_ids             = list(string)
    ssh_authorized_keys = string
    # シェープ
    shape_config = object({
      name          = string
      memory_in_gbs = number
      ocpus         = number
    })
    # ボリューム
    volume_config = object({
      size_in_gbs = number
      vpus_per_gb = number
    })
    # イメージ
    image_id = string
  })
}
