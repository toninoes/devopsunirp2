#!/bin/bash

if [ "$1" != "" ]; then
    scp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub  adminUsername@$1:~/.ssh
	ssh adminUsername@$1 '''
	sudo yum install epel-release -y
	sudo yum install ansible git -y
	sudo sed '/host_key_checking/s/^#//g' -i /etc/ansible/ansible.cfg
	git clone https://github.com/toninoes/devopsunirp2.git
	cd devopsunirp2/ansible/
	./deploy.sh
	'''
else
    echo "Necesito IP pública de master como argumento de este script. Ejecute de nuevo."
fi
