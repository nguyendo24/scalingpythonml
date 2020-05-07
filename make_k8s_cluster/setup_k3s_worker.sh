#!/bin/bash
# Note: later we assume that we end up with a static mapping of host:ip for master
# so please setup on your DHCP server
echo "k8s-worker-$(uuidgen)" > /etc/hostname
hostname $(cat /etc/hostname)
avahi-daemon  -r
# Wait for avahi to discover the master
for i in {1..10}; do
  sleep ${i}
  ping -c 2 k8s-master.local && break
done
K3S_TOKEN=$(ssh root@k8s-master.local cat /var/lib/rancher/k3s/server/node-token)
curl -sfL https://get.k3s.io | K3S_URL=https://k8s-master.local:6443 K3S_TOKEN=${K3S_TOKEN} sh -
