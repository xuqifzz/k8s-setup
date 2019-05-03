#!/bin/bash
set -e 
source /tmp/k8s-setup/node-ip.sh
source /opt/k8s/bin/environment.sh

echo ">>>>> 检查服务运行状态"
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl status kubelet|grep Active"
  done
#journalctl -u kubelet
echo ">>>>> 查看 kublet 的情况"
kubectl get csr
kubectl get nodes


echo ">>>>> kubelet 提供的 API 接口"
netstat -lnpt|grep kubelet

echo ">>>>> 证书认证和授权"
curl -s --cacert /etc/kubernetes/cert/ca.pem --cert /opt/k8s/work/cert/admin.pem --key /opt/k8s/work/cert/admin-key.pem https://${MASTER_IP}:10250/metrics|head

echo ">>>>> 获取 kublet 的配置"

curl -sSL --cacert /etc/kubernetes/cert/ca.pem --cert /opt/k8s/work/cert/admin.pem --key /opt/k8s/work/cert/admin-key.pem ${KUBE_APISERVER}/api/v1/nodes/master/proxy/configz | jq  '.kubeletconfig|.kind="KubeletConfiguration"|.apiVersion="kubelet.config.k8s.io/v1beta1"'

