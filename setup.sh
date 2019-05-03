#!/bin/bash
set -e 
bash init-ip.sh
bash init-ssh-key.sh
bash init-hostname.sh
bash execute-allnode.sh init-global.sh
bash distribute-environment.sh



