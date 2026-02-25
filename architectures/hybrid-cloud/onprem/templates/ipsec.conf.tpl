config setup
 uniqueids=yes

conn %default
 keyexchange=ikev2
 authby=psk
 ike=aes256-sha2_256-modp2048!
 esp=aes256-sha2_256!
 dpdaction=restart
 dpddelay=10s
 dpdtimeout=30s
 left=${CGW_LAN_IP}
 leftsubnet=${CGW_LAN_CIDR}
 rightsubnet=${VPC1_CIDR},${VPC2_CIDR}
 auto=start

conn AWS-VPC-GW1
 right=${T1_AWS_OUTSIDE_IP}

conn AWS-VPC-GW2
 right=${T2_AWS_OUTSIDE_IP}
