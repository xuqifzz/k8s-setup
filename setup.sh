#!/bin/bash
set -e 
export SETUP_HOME=`pwd`
bash init-ip.sh
bash init-ssh-key.sh
bash init-hostname.sh
bash execute-allnode.sh init-global.sh
bash distribute-environment.sh
bash init-cfssl.sh
bash init-cert.sh
bash init-kubectl.sh
bash init-etcd.sh
bash init-flannel.sh
bash init-kube-nginx.sh
bash init-master.sh




