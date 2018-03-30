# Nomad for Terraform

This module deploys an entire Nomad/Consul cluster, with minimal configuration.

The module can deploy both masters and slaves, in one call, or can be used to deploy them separately.

The module also includes support for AWS Elastic Container Registry (ECR), and will automatically get credentials for the slave nodes.

## Example:
```
module "nomad" {
  source = "git@github.com:patch-notes/terraform-nomad.git"
  num_masters = 1
  num_slaves = 1
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  master_instance_type = "t2.micro"
  cidr_vpc = "10.0.0.0/16"
  cidr_masters = "10.0.0.0/24"
  cidrs_slaves = ["10.0.1.0/24", "10.0.2.0/24"]
  key_name = "main"
  slave_target_group_arns = ["${aws_lb_target_group.gateway.arn}"]
  slave_instance_type = "t2.micro"
}
```

## Parameters
### cidr_vpc
The range for the masters' and slaves' VPC.
_default = "192.168.0.0/16"_

### cidr_masters
The IP range for the masters' subnet.
_default = "192.168.0.0/24"_

### cidrs_slaves
The ranges for the slaves' subnets.
_default = ["192.168.1.0/24", "192.168.2.0/24"]_

### num_masters
The number of master nodes
_default = 3_

### num_slaves
The number of slave nodes
_default = 1_

### availability_zones
The availability zones where masters and slaves will be deployed.

### key_name
The name of the SSH key to deploy to masters and slaves.

### master_instance_type
The instance type for the masters
_default = "m4.large_

### slave_instance_type
The instance type for the slaves
_default = "m4.large_

### slave_instance_name
The instance name for slaves
_default = "nomad-slave"_

### master_instance_name
The instance name for slaves
_default = "nomad-master"_

### slave_target_group_arns
The ARNs of the Target Group to which the slaves are attached, to use with an Application Load Balancer (ALB).
_default = []_
