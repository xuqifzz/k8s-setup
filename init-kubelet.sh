#!/bin/bash
set -e 
echo ">>>>> 创建 kubelet bootstrap kubeconfig 文件..."

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
  do
    echo ">>> ${node_name}"

    # 创建 token
    export BOOTSTRAP_TOKEN=$(kubeadm token create \
      --description kubelet-bootstrap-token \
      --groups system:bootstrappers:${node_name} \
      --kubeconfig ~/.kube/config)

    # 设置集群参数
    kubectl config set-cluster kubernetes \
      --certificate-authority=/etc/kubernetes/cert/ca.pem \
      --embed-certs=true \
      --server=${KUBE_APISERVER} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置客户端认证参数
    kubectl config set-credentials kubelet-bootstrap \
      --token=${BOOTSTRAP_TOKEN} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置上下文参数
    kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置默认上下文
    kubectl config use-context default --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig
  done

echo ">>>>> 分发 bootstrap kubeconfig 文件到所有 worker 节点..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
  do
    echo ">>> ${node_name}"
    scp kubelet-bootstrap-${node_name}.kubeconfig root@${node_name}:/etc/kubernetes/kubelet-bootstrap.kubeconfig
  done

echo ">>>>> 创建和分发 kubelet 参数配置文件..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
cat <<EOF | tee kubelet-config.yaml.template
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/etc/kubernetes/cert/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "${CLUSTER_DNS_DOMAIN}"
clusterDNS:
  - "${CLUSTER_DNS_SVC_IP}"
podCIDR: "${CLUSTER_CIDR}"
maxPods: 220
serializeImagePulls: false
hairpinMode: promiscuous-bridge
cgroupDriver: cgroupfs
runtimeRequestTimeout: "15m"
rotateCertificates: true
serverTLSBootstrap: true
readOnlyPort: 0
port: 10250
address: "##NODE_IP##"
EOF


cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do 
    echo ">>> ${node_ip}"
    sed -e "s/##NODE_IP##/${node_ip}/" kubelet-config.yaml.template > kubelet-config-${node_ip}.yaml.template
    scp kubelet-config-${node_ip}.yaml.template root@${node_ip}:/etc/kubernetes/kubelet-config.yaml
  done


echo ">>>>> 创建和分发 kubelet systemd unit 文件..."
cd /opt/k8s/work
cat > kubelet.service.template <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=${K8S_DIR}/kubelet
ExecStart=/opt/k8s/bin/kubelet \\
  --root-dir=${K8S_DIR}/kubelet \\
  --bootstrap-kubeconfig=/etc/kubernetes/kubelet-bootstrap.kubeconfig \\
  --cert-dir=/etc/kubernetes/cert \\
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \\
  --config=/etc/kubernetes/kubelet-config.yaml \\
  --hostname-override=##NODE_NAME## \\
  --pod-infra-container-image=registry.cn-beijing.aliyuncs.com/k8s_images/pause-amd64:3.1
  --allow-privileged=true \\
  --event-qps=0 \\
  --kube-api-qps=1000 \\
  --kube-api-burst=2000 \\
  --registry-qps=0 \\
  --image-pull-progress-deadline=30m \\
  --logtostderr=true \\
  --v=2
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
  do 
    echo ">>> ${node_name}"
    sed -e "s/##NODE_NAME##/${node_name}/" kubelet.service.template > kubelet-${node_name}.service
    scp kubelet-${node_name}.service root@${node_name}:/usr/lib/systemd/system/kubelet.service
  done

echo ">>>>> Bootstrap Token Auth 和授予权限"
kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --group=system:bootstrappers

echo ">>>>> 启动 kubelet 服务..."
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p ${K8S_DIR}/kubelet"
    ssh root@${node_ip} "/usr/sbin/swapoff -a"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kubelet && systemctl restart kubelet"
  done

echo ">>>>> 启动 kubelet 服务完毕"

echo ">>>>> 手动 approve server cert csr..."
sleep 4
PENDING_NODE=($(kubectl get csr | grep Pending | awk '{print $1}'))
for node_ip in ${PENDING_NODE[@]}
  do
    kubectl certificate approve ${node_ip}
  done

sleep 3
PENDING_NODE=($(kubectl get csr | grep Pending | awk '{print $1}'))
for node_ip in ${PENDING_NODE[@]}
  do
    kubectl certificate approve ${node_ip}
  done
echo ">>>>> 手动 approve server cert csr完毕"

