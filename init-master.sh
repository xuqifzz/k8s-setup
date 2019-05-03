#!/bin/bash
set -e 
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh

echo ">>>>> 下载kube server..."
wget https://dl.k8s.io/v1.12.3/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
tar -xzf  kubernetes-src.tar.gz

echo ">>>>> 分发kube server..."
cd /opt/k8s/work/kubernetes
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp server/bin/* root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
  done

echo ">>>>> 分发kube server完毕"

bash init-apiserver.sh
bash init-controller-manager.sh
bash init-scheduler.sh



