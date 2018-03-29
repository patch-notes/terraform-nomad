//variable  "security_group_masters_id" {}
variable "subnet_slaves" {
  type = "list"
}
variable "num_slaves" {}
variable "availability_zones" {
  type = "list"
}
variable "key_name" {}
variable "security_groups" {}
variable "instance_profile" {}
variable "instance_name" {}
variable "instance_type" {}

variable "target_group_arns" {
  type = "list"
}
