variable "compartment_id" {
  description = "コンパートメントID"
  type        = string
}

variable "vcn_cidr_blocks" {
  description = "cidrブロック"
  type        = list(string)
}

variable "vcn_display_name" {
  description = "VCN名"
  type        = string
}

variable "vcn_dns_label" {
  description = "DNSラベル"
  type        = string
}

variable "igw_display_name" {
  description = "IGW名"
  type        = string
}

variable "route_tables" {
  description = "ルートテーブル（配列）"
  type = map(object({
    name    = string
    use_igw = bool
    use_nat = bool
    use_sgw = bool
  }))
}

variable "subnets" {
  description = "サブネット（配列）"
  type = map(object({
    name            = string
    cidr            = string
    is_public       = bool
    route_table_key = string
  }))
}

# NSG
variable "nsgs" {
  description = "ネットワーク・セキュリティ・グループ（配列）"
  type = map(object({
    name = string
  }))
}

# NSGルール
variable "nsg_rules" {
  description = "NSG ルール（配列）"
  type = map(object({
    nsg_key        = string
    direction      = string
    protocol       = string
    description    = optional(string, null)
    source         = string
    port_range_min = string
    port_range_max = string
  }))

  validation {
    condition = alltrue([
      for r in values(var.nsg_rules) :
      contains(["INGRESS", "EGRESS"], r.direction)
    ])

    error_message = "direction は INGRESS または EGRESS のみ指定可能です。"
  }

  default = {}
}
