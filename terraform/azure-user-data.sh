#! /bin/bash

# Configurar resolución DNS
echo "192.168.1.110 master master.acme.es" >> /etc/hosts
echo "192.168.1.111 worker01 worker01.acme.es" >> /etc/hosts
echo "192.168.1.115 nfs nfs.acme.es" >> /etc/hosts
