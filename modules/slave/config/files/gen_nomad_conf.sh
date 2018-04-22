#!/bin/sh

. /run/metadata/coreos

INSTANCE_NAME=$(docker run --rm thepeak/awscli ec2 describe-instances \
                  --region $COREOS_EC2_REGION \
                  --instance-id $COREOS_EC2_INSTANCE_ID \
                  --query 'Reservations[0].Instances[0].Tags[?Key==`Name`].Value' \
                  --output text)

cat << EOF > /etc/nomad.conf
{
  "data_dir": "/var/lib/nomad",
  "client": {
    "enabled": true,
    "meta": {
      "instance_name" : "$INSTANCE_NAME",
      "public_ip": "$COREOS_EC2_IPV4_PUBLIC",
      "private_ip": "$COREOS_EC2_IPV4_LOCAL"
    },
    "options": {
      "docker.auth.config": "/etc/docker-auth.json"
    }
  }
  $acl
}
EOF
