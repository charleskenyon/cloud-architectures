options {
  directory "/var/cache/bind";
  recursion yes;
  allow-query { any; };
  listen-on port 53 { any; };
  listen-on-v6 { none; };
  dnssec-validation no;
};

zone "ec2.internal" {
  type forward;
  forward only;
  forwarders { ${R53_RSLV_INBOUND_ENDPOINT_IP1}; ${R53_RSLV_INBOUND_ENDPOINT_IP2}; };
};
