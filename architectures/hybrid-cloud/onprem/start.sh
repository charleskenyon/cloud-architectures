#!/usr/bin/env bash
set -e

envsubst < /templates/ipsec.conf.tpl > /etc/ipsec.conf
envsubst < /templates/ipsec.secrets.tpl > /etc/ipsec.secrets
envsubst < /templates/named.conf.tpl > /etc/bind/named.conf

echo "INFO - starting named"
mkdir -p /var/cache/bind
chmod 777 /var/cache/bind
/usr/sbin/named -g -c /etc/bind/named.conf &

sysctl -w net.ipv4.ip_forward=1

echo "INFO - starting strongswan"
ipsec start
sleep 2
ipsec statusall || true

sleep infinity
