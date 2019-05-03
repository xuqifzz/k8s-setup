#!/bin/bash
set -e 
source /tmp/k8s-setup/node-ip.sh

echo ">>>>> 1.2.3.6	分发证书文件..."

cd /tmp/k8s-setup/cert

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p /etc/kubernetes/cert"
    scp ca*.pem ca-config.json root@${node_ip}:/etc/kubernetes/cert
  done


echo ">>>>> 1.2.3.6	分发证书文件完毕"