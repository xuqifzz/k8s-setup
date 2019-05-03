k8s部署练习

```
yum install -y git && git clone https://github.com/xuqifzz/k8s-setup.git && cd k8s-setup && bash setup.sh

export MASTER_IP=167.179.110.117
export NODE1_IP=167.179.110.11

cd k8s-setup
tar xzf ssh.tgz
mv .ssh/id_rsa ~/.ssh/id_rsa
mv .ssh/id_rsa.pub ~/.ssh/id_rsa.pub

echo $NODE1_IP node1 node1 >> /etc/hosts
ssh-keyscan -H node1  >> ~/.ssh/known_hosts

ssh root@node1 "echo $MASTER_IP master master >> /etc/hosts"
```