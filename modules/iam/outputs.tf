output "instance_profile" {
  value = "${aws_iam_instance_profile.nomad.id}"
}
