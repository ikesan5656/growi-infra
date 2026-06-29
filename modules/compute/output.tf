output "growi_instance_private_ip" {
  value       = oci_core_instance.growi.private_ip
  description = "GrowiインスタンスのプライベートIPアドレス"
}
