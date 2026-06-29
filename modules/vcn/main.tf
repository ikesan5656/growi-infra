# VCNを作成
resource "oci_core_vcn" "this" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  /*byoipv6cidr_details {
    #Required
    byoipv6range_id = oci_core_byoipv6range.test_byoipv6range.id
    ipv6cidr_block  = var.vcn_byoipv6cidr_details_ipv6cidr_block
  }*/
  cidr_blocks = var.vcn_cidr_blocks
  #defined_tags                     = { "Operations.CostCenter" = "42" }
  display_name = var.vcn_display_name
  dns_label    = var.vcn_dns_label
  #freeform_tags                    = { "Department" = "Finance" }
  #ipv6private_cidr_blocks          = var.vcn_ipv6private_cidr_blocks
  #is_ipv6enabled                   = var.vcn_is_ipv6enabled
  # is_oracle_gua_allocation_enabled = true  # IPv6有効時のみ利用可能
  #security_attributes              = var.vcn_security_attributes
}

# IGW を作成
resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  display_name   = var.igw_display_name
  vcn_id         = oci_core_vcn.this.id
}

# ルートテーブルを作成
# デフォルトルートは使用せずそのまま
resource "oci_core_route_table" "these" {
  for_each = var.route_tables

  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name = each.value.name

  # インターネットゲートウェイ
  dynamic "route_rules" {
    for_each = each.value.use_igw ? [1] : []
    content {
      destination       = "0.0.0.0/0"
      network_entity_id = oci_core_internet_gateway.this.id
    }
  }

  # NATゲートウェイを作成
  resource "oci_core_nat_gateway" "this" {
    compartment_id = var.compartment_id
    vcn_id         = oci_core_vcn.this.id
    display_name   = "growi-nat-gateway"
  }

  # NATゲートウェイ
  dynamic "route_rules" {
    for_each = each.value.use_nat ? [1] : []
    content {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.this.id
    }
  }

  #Optional
}

# サブネットを作成
resource "oci_core_subnet" "these" {
  for_each = var.subnets

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  display_name               = each.value.name
  cidr_block                 = each.value.cidr
  route_table_id             = oci_core_route_table.these[each.value.route_table_key].id # 引数のオブジェクトキー指定
  prohibit_public_ip_on_vnic = !each.value.is_public
  #security_list_ids = [oci_core_security_list.nginx_security_list.id]
}

# NSG（ネットワーク・セキュリティ・グループ）
resource "oci_core_network_security_group" "these" {
  for_each = var.nsgs

  # Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id

  # Optional
  display_name = each.value.name
}

#NSGルール
resource "oci_core_network_security_group_security_rule" "these" {
  for_each = var.nsg_rules

  # Required
  network_security_group_id = oci_core_network_security_group.these[each.value.nsg_key].id
  direction                 = each.value.direction
  protocol                  = each.value.protocol

  # Optional
  description = each.value.description
  source      = each.value.source
  tcp_options {
    destination_port_range {
      min = each.value.port_range_min
      max = each.value.port_range_max
    }
  }
}
