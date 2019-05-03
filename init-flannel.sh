#!/bin/bash
set -e 

echo ">>>>> 下载和分发flanneld 二进制文件..."

cd /opt/k8s/work
mkdir flannel
wget https://github.com/coreos/flannel/releases/download/v0.10.0/flannel-v0.10.0-linux-amd64.tar.gz
tar -xzvf flannel-v0.10.0-linux-amd64.tar.gz -C flannel

cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp flannel/{flanneld,mk-docker-opts.sh} root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
  done




echo ">>>>> 创建和分发 flannel 证书和私钥..."
cd /opt/k8s/work/cert
cfssl gencert -ca=/opt/k8s/work/cert/ca.pem \
  -ca-key=/opt/k8s/work/cert/ca-key.pem \
  -config=/opt/k8s/work/cert/ca-config.json \
  -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld


source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p /etc/flanneld/cert"
    scp flanneld*.pem root@${node_ip}:/etc/flanneld/cert
  done



echo ">>>>> 创建和分发 flannel 证书和私钥完毕"

echo ">>>>> 向etcd 写入集群 Pod 网段信息..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/opt/k8s/work/cert/ca.pem \
  --cert-file=/opt/k8s/work/cert/flanneld.pem \
  --key-file=/opt/k8s/work/cert/flanneld-key.pem \
  set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 21, "Backend": {"Type": "vxlan"}}'



echo ">>>>> 创建和分发 flanneld 的 systemd unit 文件..."
cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
cat > flanneld.service << EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=/opt/k8s/bin/flanneld \\
  -etcd-cafile=/etc/kubernetes/cert/ca.pem \\
  -etcd-certfile=/etc/flanneld/cert/flanneld.pem \\
  -etcd-keyfile=/etc/flanneld/cert/flanneld-key.pem \\
  -etcd-endpoints=${ETCD_ENDPOINTS} \\
  -etcd-prefix=${FLANNEL_ETCD_PREFIX} \\
  -iface=${IFACE} \\
  -ip-masq
ExecStartPost=/opt/k8s/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=always
RestartSec=5
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF


source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp flanneld.service root@${node_ip}:/usr/lib/systemd/system/
  done



cd /opt/k8s/work
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    scp etcd-${node_ip}.service root@${node_ip}:/usr/lib/systemd/system/etcd.service
  done


echo ">>>>> 创建和分发flanneld systemd unit文件完毕..."


echo ">>>>> 启动 flanneld 服务..."
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable flanneld && systemctl restart flanneld"
  done


# source /opt/k8s/bin/environment.sh
# for node_ip in ${NODE_IPS[@]}
#   do
#     echo ">>> ${node_ip}"
#     ssh root@${node_ip} "systemctl status flanneld|grep Active"
#   done

echo ">>>>> 启动 etcd 服务完毕"
