#!/bin/bash
set -e 
echo ">>>>> 分发environment.sh..."
mkdir -p /tmp/k8s-setup

cp environment.sh /tmp/k8s-setup/environment.sh
bash replace-host-ip.sh /tmp/k8s-setup/environment.sh

source /tmp/k8s-setup/node-ip.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>>>> 向${node_ip}分发environment.sh..."
    scp /tmp/k8s-setup/environment.sh root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
  done
echo "source /opt/k8s/bin/environment.sh" >> /root/.bashrc
echo ">>>>> 分发environment.sh完毕"