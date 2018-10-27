resource "aws_security_group" "nomad" {
  vpc_id = "${var.vpc_id}"
  name   = "nomad_master"
}

/*
resource "aws_security_group_rule" "ssh_in" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.nomad.id}"
}*/

resource "aws_security_group_rule" "nomad_tcp_in" {
  type      = "ingress"
  from_port = 4646
  to_port   = 4648
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "consul_tcp_in" {
  type      = "ingress"
  from_port = 8300
  to_port   = 8302
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "consul_http_tcp_in" {
  type      = "ingress"
  from_port = 8500
  to_port   = 8500
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "nomad_udp_in" {
  type      = "ingress"
  from_port = 4646
  to_port   = 4648
  protocol  = "udp"
  self      = true

  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "consul_udp_in" {
  type      = "ingress"
  from_port = 8300
  to_port   = 8302
  protocol  = "udp"
  self      = true

  security_group_id = "${aws_security_group.nomad.id}"
}

resource "aws_security_group_rule" "out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.nomad.id}"
}
