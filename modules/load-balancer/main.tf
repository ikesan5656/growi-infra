resource "oci_load_balancer_load_balancer" "this" {

  # Required
  compartment_id = var.compartment_id
  display_name   = "test"
  # 無料枠に抑えるための設定
  shape = "flexible"
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
  subnet_ids = var.load_balancer_subnet_ids

  # Optional
  is_private = false
}

# バックエンド(Growi)のOCIインスタンス向けの設定

# 転送ルール
resource "oci_load_balancer_backend_set" "growi" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = "growi-bes"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol    = "HTTP"
    url_path    = "/"
    port        = 80
    return_code = 200
  }
}

# バックエンド紐付け
resource "oci_load_balancer_backend" "growi_backend" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.growi.name
  ip_address       = var.target_private_ip
  port             = 80
}

resource "oci_load_balancer_listener" "https_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = "https-listener"
  default_backend_set_name = oci_load_balancer_backend_set.growi.name
  port                     = 443
  protocol                 = "HTTP"

  # SSL証明書の設定（証明書リソースを別途作成して紐付ける）
  /*ssl_configuration {
    certificate_name = oci_load_balancer_certificate.growi_cert.certificate_name
  }*/
}
