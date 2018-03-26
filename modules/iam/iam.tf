data "aws_iam_policy_document" "nomad_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ec2:Describe*"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "nomad_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "nomad" {
  name   = "nomad"
  role   = "${aws_iam_role.nomad.id}"
  policy = "${data.aws_iam_policy_document.nomad_policy.json}"
}

resource "aws_iam_role" "nomad" {
  assume_role_policy = "${data.aws_iam_policy_document.nomad_assume_role.json}"
  name               = "nomad"
}

resource "aws_iam_instance_profile" "nomad" {
  name = "nomad"
  role = "${aws_iam_role.nomad.id}"
}
