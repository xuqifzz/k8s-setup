#!/bin/bash
set -e
echo ">>>>> 初始化cert配置文件..."
export PATH=/opt/k8s/bin:$PATH
rm -rf /opt/k8s/work/cert
cp -rf cert/ /opt/k8s/work/cert

REPLACE_FILE=(etcd-csr.json harbor-csr.json kube-controller-manager-csr.json kubernetes-csr.json kube-scheduler-csr.json 
registry-csr.json) 

for json_file in ${REPLACE_FILE[@]}
  do
    bash replace-host-ip.sh /opt/k8s/work/cert/${json_file}
  done

cd /opt/k8s/work/cert
cfssl gencert -initca ca-csr.json | cfssljson -bare ca


echo ">>>>> 初始化cert配置文件完毕"

source /tmp/k8s-setup/node-ip.sh
echo ">>>>> 分发证书文件..."

cd /opt/k8s/work/cert

for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p /etc/kubernetes/cert"
    scp ca*.pem ca-config.json root@${node_ip}:/etc/kubernetes/cert


  done


echo ">>>>> 分发证书文件完毕"