#!/bin/bash
set -e 
bash init-ip.sh
bash init-ssh-key.sh
bash init-hostname.sh
bash execute-allnode.sh init-global.sh
bash distribute-environment.sh
bash init-cfssl.sh
bash init-cert.sh
bash init-kubectl.sh
bash init-etcd.sh
#bash check-etcd.sh
bash init-flannel.sh




