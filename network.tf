data "aws_availability_zones" "available" {}

resource "aws_vpc" "nomad" {
  cidr_block = "${var.cidr_vpc}"
}

resource "aws_subnet" "masters" {
  vpc_id     = "${aws_vpc.nomad.id}"
  cidr_block = "${var.cidr_masters}"

  tags {
    Name = "nomad-masters"
  }
}

resource "aws_subnet" "slaves" {
  count             = "${length(var.cidrs_slaves)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block        = "${element(var.cidrs_slaves, count.index)}"
  vpc_id            = "${aws_vpc.nomad.id}"

  tags {
    Name = "nomad-slaves"
  }
}

resource "aws_internet_gateway" "nomad" {
  vpc_id = "${aws_vpc.nomad.id}"
}

resource "aws_route_table" "nomad" {
  vpc_id = "${aws_vpc.nomad.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.nomad.id}"
  }
}

resource "aws_route_table_association" "masters" {
  subnet_id      = "${aws_subnet.masters.id}"
  route_table_id = "${aws_route_table.nomad.id}"
}

resource "aws_route_table_association" "slaves" {
  count          = "${length(var.cidrs_slaves)}"
  subnet_id      = "${element(aws_subnet.slaves.*.id, count.index)}"
  route_table_id = "${aws_route_table.nomad.id}"
}
