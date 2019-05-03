#!/bin/bash
set -e 
source /tmp/k8s-setup/node-ip.sh

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>>>> 在 ${node_ip} 执行 $1..."
    ssh root@${node_ip} "mkdir -p /tmp/k8s-setup"
    scp $1 root@${node_ip}:/tmp/k8s-setup/$1
    ssh root@${node_ip} "bash /tmp/k8s-setup/$1"
    echo ">>>>> 在 ${node_ip} 执行 $1完毕"
  done


