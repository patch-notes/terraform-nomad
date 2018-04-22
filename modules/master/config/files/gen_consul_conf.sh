#!/bin/sh

. /run/metadata/coreos

cat > /etc/consul.json << EOF
{
  "server": true,
  "bootstrap_expect": ${num_masters},
  "advertise_addr": "$COREOS_EC2_IPV4_LOCAL",
  "client_addr": "0.0.0.0",
  "data_dir": "/var/lib/consul",
  "retry_join": ["provider=aws tag_key=Name tag_value=${instance_name}"],
  "ui": true

  ${acl}
}
EOF
