module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = "${aws_vpc.nomad.id}"
}

module "iam" {
  source = "./modules/iam"
}

module "master_asg" {
  source = "./modules/master/asg"

  num_masters        = "${var.num_masters}"
  vpc_id             = "${aws_vpc.nomad.id}"
  key_name           = "${var.key_name}"
  vpc_cidr           = "${var.cidr_vpc}"
  subnet_masters_id  = "${aws_subnet.masters.id}"
  availability_zones = "${var.availability_zones}"
  instance_type      = "${var.master_instance_type}"
  instance_profile   = "${module.iam.instance_profile}"
  security_groups    = ["${module.security_groups.main}"]
  instance_name      = "${var.master_instance_name}"
}

module "slave_asg" {
  source = "./modules/slave/asg"

  num_slaves         = "${var.num_slaves}"
  subnet_slaves      = "${aws_subnet.slaves.*.id}"
  availability_zones = "${var.availability_zones}"
  instance_type      = "${var.slave_instance_type}"
  key_name           = "${var.key_name}"
  security_groups    = "${concat(list(module.security_groups.main), var.slave_security_gruops)}"
  instance_profile   = "${module.iam.instance_profile}"
  instance_name      = "${var.slave_instance_name}"
  master_instance_name = "${var.master_instance_name}"

  target_group_arns = "${var.slave_target_group_arns}"
}
