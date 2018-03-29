data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*-hvm"]
  }
}

resource "aws_autoscaling_group" "nomad_slaves" {
  count = "${var.num_slaves != 0 ? 1 : 0}"

  availability_zones        = ["${var.availability_zones}"]
  name                      = "${var.instance_name}"
  max_size                  = "${var.num_slaves}"
  min_size                  = "${var.num_slaves}"
  health_check_grace_period = 300
  desired_capacity          = "${var.num_slaves}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.nomad_slaves.name}"
  vpc_zone_identifier       = ["${var.subnet_slaves}"]

  tag {
    key                 = "Name"
    value               = "${var.instance_name}"
    propagate_at_launch = true
  }

  target_group_arns = ["${var.target_group_arns}"]
}

resource "aws_launch_configuration" "nomad_slaves" {
  count = "${var.num_slaves != 0 ? 1 : 0}"

  name_prefix                 = "${var.instance_name}"
  image_id                    = "${data.aws_ami.coreos.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
  security_groups             = ["${var.security_groups}"]
  enable_monitoring           = false
  iam_instance_profile        = "${var.instance_profile}"

  user_data = "${module.config.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

module "config" {
  source      = "../config"
}
