#!/bin/bash

# añadir tantas líneas como sean necesarias para el correcto despligue
ansible-playbook -i hosts 01-todos_hosts.yaml
ansible-playbook -i hosts --limit nfs 02-servidor_nfs.yaml
