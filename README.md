# Práctica 2 del curso de Experto en Devops &amp; Cloud de UNIR

Consiste en desplegar un clúster de Kubernetes en Azure utilizando para ello Terraform y Ansible.

Vamos a desplegarlas en una subred **192.168.1.0/24** las IP privadas de las máquinas serán:

| Nombre | IP |
|------|------|
| nfs.acme.es  | 192.168.1.115/24 |
| master.acme.es | 192.168.1.110/24 | 
| worker01.acme.es | 192.168.1.111/24 | 

Debido a las limitaciones de la cuenta Azure student de 4 vCPU y ya que la maquina que actúa como master necesita al menos 2 de ellos, hemos tenido que reducir a sólo 1 worker. Quedándonos así:

| Role | Sistema Operativo / Tipo | vCPUs | Memoria (GiB) | Disco Duro |
|------|-------------------|-------|---------------|------------|
| nfs  | CentOS 8 / Standard_DS1_v2           | 1     | 4             | 1 x 30 GiB |
| master | CentOS 8 / Standard_D2s_v3        | 2     | 8             | 1 x 30 GiB |
| worker01 | CentOS 8 / Standard_DS1_v2       | 1     | 4             | 1 x 30 GiB |

Debemos tener un par de claves en nuestro equipo, ya que se copiarán a las maquinas virtuales azure en el despliegue y las utilizaremos también luego para el nodo master que hará de controller de ansible, para ello hacemos en nuestro equipo:

```console
toni@tonipc:~$ ssh-keygen -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key (/home/toni/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in id_rsa
Your public key has been saved in id_rsa.pub
The key fingerprint is:
SHA256:d6ePc0yE/+ZhkgTgxPq345n4iEV5vmbUnCUFt0YXPPUc tonipc
The key's randomart image is:
+---[RSA 4096]----+
|        o+..o o. |
|        oo.o o  E|
|        ..o. .o..|
|     . o . .o .+o|
|    . o S B ++. o|
|     o   O =.++  |
|      . +   += + |
|     . = .  .o= +|
|      +.+   .o.o.|
+----[SHA256]-----+
```

## Terraform
En el directorio terraform de este repositorio se encuentra lo necesario para deplegar toda la infraestructura en Azure.

### Instrucciones de despliegue de la infraestructura Azure
En primer lugar deberás alojar en este mismo directorio tu fichero de credenciales credentials.tf que tiene la siguiente estructura:

```
 provider "azurerm" {
  features {}
  subscription_id = "<SUBSCRIPCION ID>"
  client_id       = "<APP_ID>"
  client_secret   = "<PASSWORD>"
  tenant_id       = "<TENANT>"
}
```

Estos datos se obtendrán al hacer az login con el cli de Azure.

Como en esta practica vamos a usar Centos8, deberas aceptar los terminos de uso de dicha imagen en Azure con

```console
[toni@tonipc: ~]# az vm image terms accept --urn cognosys:centos-8-stream-free:centos-8-stream-free:1.2019.0810
```

Todo esto lo puedes hacer directamente en la Cloud Shell de la consola de Azure, si no quieres instalar el cliente en local.

Debes de disponer de la última versión de Terraform instalada y finalmente ejecutar los siguientes comandos dentro del directorio terraform:

```console
toni@tonipc:~/devopsunirp2/terraform$ terraform init
toni@tonipc:~/devopsunirp2/terraform$ terraform plan
toni@tonipc:~/devopsunirp2/terraform$ terraform apply
```

## Ansible
Contiene todos los ficheros necesarios para desplegar el cluster de Kubernetes y la aplicación.
