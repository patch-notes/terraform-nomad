output "subnet_masters_id" {
  value = "${aws_subnet.masters.id}"
}

output "subnet_slaves_ids" {
  value = ["${aws_subnet.slaves.*.id}"]
}

output "subnet_slaves_ids_num" {
  value = "${length(var.cidrs_slaves)}"
}

output "vpc_id" {
  value = "${aws_vpc.nomad.id}"
}

output "instance_profile" {
  value = "${module.iam.instance_profile}"
}

output "security_group" {
  value = "${module.security_groups.main}"
}
