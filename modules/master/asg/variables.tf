variable "num_masters" {}

variable "key_name" {}

variable "instance_type" {}

variable "availability_zones" {
  type = "list"
}

variable "vpc_id" {}

variable "vpc_cidr" {}

variable "subnet_masters_id" {}

variable "instance_profile" {}

variable "security_groups" {
  type = "list"
}
