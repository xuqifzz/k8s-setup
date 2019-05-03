#!/bin/bash
set -e 

echo ">>>>> 创建 kube-proxy 证书"
cd /opt/k8s/work/cert
source /opt/k8s/bin/environment.sh
cfssl gencert -ca=/opt/k8s/work/cert/ca.pem \
  -ca-key=/opt/k8s/work/cert/ca-key.pem \
  -config=/opt/k8s/work/cert/ca-config.json \
  -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy

echo ">>>>>	创建和分发 kubeconfig 文件"

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
kubectl config set-cluster kubernetes \
  --certificate-authority=/opt/k8s/work/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=/opt/k8s/work/cert/kube-proxy.pem \
  --client-key=/opt/k8s/work/cert/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
  do
    echo ">>> ${node_name}"
    scp kube-proxy.kubeconfig root@${node_name}:/etc/kubernetes/
  done

echo ">>>>>	创建和分发 kube-proxy 配置文件"
cd /opt/k8s/work
cat <<EOF | tee kube-proxy-config.yaml.template
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/etc/kubernetes/kube-proxy.kubeconfig"
bindAddress: ##NODE_IP##
clusterCIDR: ${CLUSTER_CIDR}
healthzBindAddress: ##NODE_IP##:10256
hostnameOverride: ##NODE_NAME##
metricsBindAddress: ##NODE_IP##:10249
mode: "ipvs"
EOF

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for (( i=0; i < 3; i++ ))
  do 
    echo ">>> ${NODE_NAMES[i]}"
    sed -e "s/##NODE_NAME##/${NODE_NAMES[i]}/" -e "s/##NODE_IP##/${NODE_IPS[i]}/" kube-proxy-config.yaml.template > kube-proxy-config-${NODE_NAMES[i]}.yaml.template
    scp kube-proxy-config-${NODE_NAMES[i]}.yaml.template root@${NODE_NAMES[i]}:/etc/kubernetes/kube-proxy-config.yaml
  done

echo ">>>>>	创建和分发 kube-proxy systemd unit 文件"
cd /opt/k8s/work
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/data/k8s/k8s/kube-proxy
ExecStart=/opt/k8s/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy-config.yaml \\
  --logtostderr=true \\
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
  do 
    echo ">>> ${node_name}"
    scp kube-proxy.service root@${node_name}:/usr/lib/systemd/system/
  done

echo ">>>>>	启动 kube-proxy 服务..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p ${K8S_DIR}/kube-proxy"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kube-proxy && systemctl restart kube-proxy"
  done

echo ">>>>>	启动 kube-proxy 服务完毕"
