#!/bin/bash
set -e 
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh

echo ">>>>> 创建和分发 kube-scheduler 证书和私钥..."
cd /opt/k8s/work/cert
source /opt/k8s/bin/environment.sh
cfssl gencert -ca=/opt/k8s/work/cert/ca.pem \
  -ca-key=/opt/k8s/work/cert/ca-key.pem \
  -config=/opt/k8s/work/cert/ca-config.json \
  -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler


for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p /etc/kubernetes/cert"
    scp kubernetes*.pem root@${node_ip}:/etc/kubernetes/cert/
  done

echo ">>>>> 创建和分发 kube-scheduler 证书和私钥完毕"

echo ">>>>> 创建和分发 kubeconfig 文件"
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh

kubectl config set-cluster kubernetes \
  --certificate-authority=cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=cert/kube-scheduler.pem \
  --client-key=cert/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context system:kube-scheduler \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp kube-scheduler.kubeconfig root@${node_ip}:/etc/kubernetes/
  done

echo ">>>>> 创建 kube-scheduler 配置文件"
cat <<EOF | tee kube-scheduler.yaml
apiVersion: componentconfig/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/etc/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp kube-scheduler.yaml root@${node_ip}:/etc/kubernetes/
  done



echo ">>>>> 创建和分发kube-scheduler systemd unit 文件"

cd /opt/k8s/work
cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
WorkingDirectory=${K8S_DIR}/kube-scheduler
ExecStart=/opt/k8s/bin/kube-scheduler \\
  --config=/etc/kubernetes/kube-scheduler.yaml \\
  --address=127.0.0.1 \\
  --kube-api-qps=100 \\
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
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp kube-scheduler.service root@${node_ip}:/etc/systemd/system/
  done




echo ">>>>> 启动 kube-scheduler 服务..."
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p ${K8S_DIR}/kube-scheduler"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kube-scheduler && systemctl restart kube-scheduler"
  done


echo ">>>>> 启动 kube-scheduler 服务完毕"