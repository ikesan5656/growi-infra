output "public_subnet_ids" {
  value = {
    for k, v in oci_core_subnet.these :
    k => v.id
    if var.subnets[k].is_public == true
  }
}

output "private_subnet_ids" {
  value = {
    for k, v in oci_core_subnet.these :
    k => v.id
    if var.subnets[k].is_public == false
  }
}

output "web_nsg_id" {
  value = oci_core_network_security_group.these["web"].id
}
