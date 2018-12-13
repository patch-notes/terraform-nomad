variable "master_instance_name" {
  default = "nomad-master"
}

variable "docker_ip" {
  default = "172.17.0.1"
}

variable "docker_subnet" {
  default = "24"
}

variable "consul_acl_enable" {
  default = false
}

variable "consul_acl_client_token" {
  default = ""
}

variable "extra_fs" {
  default = []
}

variable "swap_size" {
  default = "0"
}
