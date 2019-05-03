#!/bin/bash
set -e
echo ">>>>> 初始化cert配置文件..."
rm -rf /tmp/k8s-setup/cert
cp -rf cert/ /tmp/k8s-setup/cert

REPLACE_FILE=(etcd-csr.json harbor-csr.json kube-controller-manager-csr.json kubernetes-csr.json kube-scheduler-csr.json 
registry-csr.json) 

for json_file in ${REPLACE_FILE[@]}
  do
    bash replace-host-ip.sh /tmp/k8s-setup/cert/${json_file}
  done

cd /tmp/k8s-setup/cert
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
echo ">>>>> 初始化cert配置文件完毕"