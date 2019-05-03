#!/bin/bash

echo ">>>>> 检查 etcd集群状态"
bash check-etcd.sh

echo ">>>>> 检查 flannel网络状态"
bash check-flannel.sh

echo ">>>>> 检查 kube-nginx 服务运行状态"
bash check-kube-nginx.sh

echo ">>>>> 检查 kube-apiserver集群状态"
bash check-apiserver.sh

echo ">>>>> 检查 controller-manager集群状态"
bash check-controller-manager.sh

echo ">>>>> 检查 scheduler集群状态"
bash check-scheduler.sh

echo ">>>>> 检查 docker运行状态"
bash check-docker.sh

echo ">>>>> 检查 kubelet运行状态"
bash check-kubelet.sh

