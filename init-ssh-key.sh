#!/bin/bash
set -e
echo ">>>>> 配置Master SSH密钥..."
tar xzf ssh.tgz
mkdir -p /root/.ssh
chmod 600 /root/.ssh
mv .ssh/id_rsa ~/.ssh/id_rsa
mv .ssh/id_rsa.pub ~/.ssh/id_rsa.pub
echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvGzyuleAd62hb/Sj0aW/7ls34UFjvMLcHFcFnPXAXMjjvw2zP+w9gqgLQCLYA4uhdipHoJxulC6PkMHx64AFDJK4BB2MRGtfFUWla7e2d4FHpnomCIxhx/Iv7uGMYvS/CsqzKCELU2u/5SNdXD1fJKaAILUMIQaRBq32w0nk7PFkGuf++uqZOpL2eR9MvyWDpixseC3ss36IEIm1tRyoU9XT5QThz1a+LDHQ7DnsmVDV8r9CZHG6uermC9aSweq8G8Jo7gSzMUpEV5OJNv/WL1O13rPY0pLtKT7LuQxz2j6bX2X7E8zqNxRU6K3o8Xz7vp/Syaw8wGPQMy+5O6m5f root@master >> /root/.ssh/authorized_keys
echo ">>>>> 配置Master SSH密钥完毕"