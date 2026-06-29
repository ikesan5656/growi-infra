variable "compartment_id" {
  description = "コンパートメントID"
  type        = string
}

variable "target_private_ip" {
  description = "ターゲットIP"
  type        = string
}

variable "load_balancer_subnet_ids" {
  description = "対象のサブネット"
  type        = list(string)
}
