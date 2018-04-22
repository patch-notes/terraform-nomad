#!/bin/sh

. /run/metadata/coreos

DNS_SERVER=$(awk '/nameserver/ {if ($2 != "${docker_ip}") print $2}' /etc/resolv.conf) \

cat > /etc/consul.json << EOF
{
  "ports": {
    "dns": 53
  },
  "recursors": ["$DNS_SERVER"],
  "client_addr": "0.0.0.0",
  "advertise_addr": "$COREOS_EC2_IPV4_LOCAL",
  "retry_join": ["provider=aws tag_key=Name tag_value=${master_instance_name}"],
  "datacenter": "dc1"
  ${acl}
}
EOF
