module "global_variables" {
  # アカウント間で共通で使用する変数
  source = "../../modules/global-variables"
}

locals {
  # modules/global-variables/main.tfから参照
  project_name = module.global_variables.project_name
}

data "oci_identity_compartments" "dev" {
  compartment_id = var.tenancy_ocid
  name           = "dev"
  access_level   = "ACCESSIBLE"
}

# コンパートメント
resource "oci_identity_compartment" "this" {
  compartment_id = data.oci_identity_compartments.dev.compartments[0].id # 親のコンパートメントOCID
  name           = local.project_name
  description    = "Growi compartment"
}

# vcn
module "vcn" {
  source = "../../modules/vcn"
  #version = "3.6.0"
  # insert the 1 required variable here
  compartment_id = oci_identity_compartment.this.id

  # Optional Inputs
  vcn_cidr_blocks  = ["10.0.0.0/16", "192.168.0.0/16"]
  vcn_display_name = local.project_name
  vcn_dns_label    = "terraform"
  igw_display_name = "igw2"
  # ルートテーブル
  route_tables = {
    public = {
      name    = "public-route-table"
      use_igw = true
      use_nat = false
      use_sgw = false
    }
    private = {
      name    = "private-route-table"
      use_igw = false
      use_nat = false
      use_sgw = false
    }
  }
  # サブネット
  subnets = {
    public_subnet = {
      name            = "pub-sub"
      cidr            = "10.0.1.0/24",
      is_public       = true
      route_table_key = "public"
    }
    private_subnet = {
      name            = "priv-sub"
      cidr            = "10.0.2.0/24",
      is_public       = false
      route_table_key = "private"
    }
  }
  # NSG
  nsgs = {
    web = {
      name = "web-nsg"
    }
  }

  nsg_rules = {
    https = {
      nsg_key        = "web"
      direction      = "INGRESS"
      protocol       = "6" # TCP
      description    = "https用"
      source         = "0.0.0.0/0"
      port_range_min = "443"
      port_range_max = "443"
    }
    http = {
      nsg_key        = "web"
      direction      = "INGRESS"
      description    = "http用"
      protocol       = "6" # TCP
      source         = "0.0.0.0/0"
      port_range_min = "80"
      port_range_max = "80"
    }
    ssh = {
      nsg_key        = "web"
      direction      = "INGRESS"
      description    = "ssh用"
      protocol       = "6" # TCP
      source         = "0.0.0.0/0"
      port_range_min = "22"
      port_range_max = "22"
    }
  }
}

# compute
module "compute" {
  source         = "../../modules/compute"
  compartment_id = oci_identity_compartment.this.id
  compute_settings = {
    name                = "Growi-free-Ampere"
    availability_domain = "zThk:AP-TOKYO-1-AD-1"
    subnet_id           = one(values(module.vcn.private_subnet_ids))
    nsg_ids             = [module.vcn.web_nsg_id]
    ssh_authorized_keys = var.ssh_authorized_keys
    shape_config = {
      name          = "VM.Standard.A1.Flex"
      memory_in_gbs = 12
      ocpus         = 2
    }
    volume_config = {
      size_in_gbs = 100
      vpus_per_gb = 10
    }
    image_id = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa5nza3kjb7qatctld6je2kw6jr2x3ae3gimsq5gpiik7wddp4mytq"
  }

}

# ロードバランサー
module "load_balancer" {
  source                   = "../../modules/load-balancer"
  compartment_id           = oci_identity_compartment.this.id
  target_private_ip        = module.compute.growi_instance_private_ip
  load_balancer_subnet_ids = [module.vcn.public_subnet_ids["public"]]
}
