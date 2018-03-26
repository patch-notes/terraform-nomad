variable "cidr_vpc" {
  default = "192.168.0.0/16"
}

variable "cidr_masters" {
  default = "192.168.0.0/24"
}

variable "cidrs_slaves" {
  type    = "list"
  default = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "num_masters" {
  default = 3
}

variable "num_slaves" {
  default = 1
}

variable "availability_zones" {
  type = "list"
}

variable "key_name" {}

variable "master_instance_type" {
  default = "m4.large"
}
