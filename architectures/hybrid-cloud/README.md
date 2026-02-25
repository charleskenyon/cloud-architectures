diagram (draw.io or Mermaid)

“From on-prem instance, resolve service.internal and reach endpoint”

“Prove routing with traceroute / curl”

---

zone "url" {
type forward;
forward only;
forwarders { 0.0.0.0 };
}

nano /etc/named.conf
sudo service named restart

echo "192.241.xx.xx venus.example.com venus" >> /etc/hosts

create NS record on alpine

---

## Deployment Validation

After provisioning infrastructure, this repo provides a script
(`deploy-and-test-connectivity.sh`) that performs remote connectivity
checks using AWS SSM.

This simulates real-world infrastructure smoke testing by validating
network reachability between private instances without SSH access.

https://wiki.alpinelinux.org/wiki/Small-Time_DNS_with_BIND9#Add_Zones_for_localhost
