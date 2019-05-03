#!/bin/bash
set -e 
source /opt/k8s/bin/environment.sh

echo ">>>>> 下载kubectl..."
cd /opt/k8s/work

wget https://dl.k8s.io/v1.12.3/kubernetes-client-linux-amd64.tar.gz
tar -xzvf kubernetes-client-linux-amd64.tar.gz
echo ">>>>> 分发kubectl..."
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp kubernetes/client/bin/kubectl root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
  done

echo ">>>>> 分发kubectl完毕"

echo ">>>>> 创建admin证书和私钥.."
cd /opt/k8s/work/cert
cfssl gencert -ca=/opt/k8s/work/cert/ca.pem \
  -ca-key=/opt/k8s/work/cert/ca-key.pem \
  -config=/opt/k8s/work/cert/ca-config.json \
  -profile=kubernetes admin-csr.json | cfssljson -bare admin

echo ">>>>> 创建admin证书和私钥完毕"



echo ">>>>> 创建 kubeconfig 文件..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh


# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/opt/k8s/work/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubectl.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials admin \
  --client-certificate=/opt/k8s/work/cert/admin.pem \
  --client-key=/opt/k8s/work/cert/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubectl.kubeconfig

# 设置上下文参数
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=kubectl.kubeconfig
  
# 设置默认上下文
kubectl config use-context kubernetes --kubeconfig=kubectl.kubeconfig



echo ">>>>> 分发kubeconfig 文件..."
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p ~/.kube"
    scp kubectl.kubeconfig root@${node_ip}:~/.kube/config
  done



echo ">>>>> 分发kubeconfig 文件完毕"



