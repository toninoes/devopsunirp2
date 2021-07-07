#!/bin/bash

# añadir tantas líneas como sean necesarias para el correcto despligue
ansible-playbook -i hosts 01-todos_hosts.yaml
ansible-playbook -i hosts 02-servidor_nfs.yaml
ansible-playbook -i hosts 03-master_workers.yaml
ansible-playbook -i hosts 04-master.yaml
ansible-playbook -i hosts 05-workers.yaml
ansible-playbook -i hosts 06-guardar_token_master.yaml
ansible-playbook -i hosts 07-unir_workers_cluster.yaml
