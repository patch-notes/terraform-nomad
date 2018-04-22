//variable  "security_group_masters_id" {}
variable "subnet_slaves" {
  type = "list"
}

variable "num_slaves" {}

variable "availability_zones" {
  type = "list"
}

variable "key_name" {}
variable "security_groups" {
  type = "list"
}
variable "instance_profile" {}
variable "instance_name" {}
variable "instance_type" {}

variable "target_group_arns" {
  type = "list"
}

variable "master_instance_name" {}

variable "consul_acl_enable" {}
variable "consul_acl_client_token" {}
