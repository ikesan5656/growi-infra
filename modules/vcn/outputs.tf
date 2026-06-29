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

output "lb_nsg_id" {
  value = oci_core_network_security_group.these["lb_nsg"].id
}

output "instance_nsg_id" {
  value = oci_core_network_security_group.these["instance_nsg"].id
}
