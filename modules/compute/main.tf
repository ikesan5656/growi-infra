# Compute モジュールファイル
resource "oci_core_instance" "growi" {
  # Required
  compartment_id      = var.compartment_id
  availability_domain = var.compute_settings.availability_domain
  shape               = var.compute_settings.shape_config.name
  display_name        = var.compute_settings.name

  agent_config {
    # 以下の２つは基本有効化
    is_management_disabled = "false"
    is_monitoring_disabled = "false"
    plugins_config {
      # Oracle の WebLogic Server 管理用 WebLogicを使っている場合のみ
      desired_state = "DISABLED"
      name          = "WebLogic Management Service"
    }
    plugins_config {
      # OSパッケージの脆弱性スキャン
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      # JVMの可視化 Javaアプリを詳細管理したい場合のみのため通常は不要
      desired_state = "DISABLED"
      name          = "Oracle Java Management Service"
    }
    plugins_config {
      # OSアップデート集中管理
      desired_state = "DISABLED"
      name          = "OS Management Hub Agent"
    }
    plugins_config {
      # Oracle製品（DBなど）の監視エージェント
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      # 複数アプリの一元管理 一般Web用途では不要
      desired_state = "DISABLED"
      name          = "Fleet Application Management Service"
    }
    plugins_config {
      # OS内ログを OCI Logging に送信可能
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      # GPU使用率監視
      desired_state = "DISABLED"
      name          = "Compute RDMA GPU Monitoring"
    }
    plugins_config {
      # コンソールやAPIからコマンド実行可 本番でも推奨
      desired_state = "ENABLED"
      name          = "Compute Instance Run Command"
    }
    plugins_config {
      # 基本メトリクス（CPU / Memory など）収集 本番でも推奨
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      # スーパーコンピュータ用途
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Auto-Configuration"
    }
    plugins_config {
      # スーパーコンピュータ用途
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Authentication"
    }
    plugins_config {
      # Cloud Guardと連携し、マルウェア、異常検出　推奨設定
      desired_state = "ENABLED"
      name          = "Cloud Guard Workload Protection"
    }
    plugins_config {
      # ブロックボリューム管理の拡張制御 通常はComputeから直接制御するので不要
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      # SSH踏み台をOCI管理下に置く場合のみ必要
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE" # 復旧後、インスタンスが実行中だった場合は、自動的に再起動される
  }
  create_vnic_details {
    assign_ipv6ip             = "false"
    assign_private_dns_record = "true"
    assign_public_ip          = "true"
    subnet_id                 = var.compute_settings.subnet_id
    nsg_ids                   = var.compute_settings.nsg_ids
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  is_pv_encryption_in_transit_enabled = "true" # データボリュームの準仮想化アタッチメントに対して転送中の暗号化を有効
  metadata = {
    "ssh_authorized_keys" = var.compute_settings.ssh_authorized_keys
  }
  # シェープの性能
  shape_config {
    memory_in_gbs = var.compute_settings.shape_config.memory_in_gbs
    ocpus         = var.compute_settings.shape_config.ocpus
  }
  source_details {
    boot_volume_size_in_gbs = var.compute_settings.volume_config.size_in_gbs # ブートボリュームサイズ(GB)
    boot_volume_vpus_per_gb = var.compute_settings.volume_config.vpus_per_gb # このボリュームに適用されるボリューム・パフォーマンス・ユニット (VPU) の数（GB あたり）
    # Oracle-Linux-9.6-aarch64-2025.11.20-0のイメージ
    source_type = "image" # イメージで固定
    source_id   = var.compute_settings.image_id
  }
}
