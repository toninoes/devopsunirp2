# Despliegue de clúster de Kubernetes en Azure utilizando Terraform y Ansible.

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
Una vez desplegada toda la infraestructura con Terraform, vamos a conectarnos al nodo master por ssh el cual será desde donde lanzaremos los comandos de ansible, pero antes desde nuestro equipo local haremos:

```console
toni@tonipc:~$ MASTER=100.111.122.133 # IP pública asignada a master en Azure
toni@tonipc:~$ scp ~/.ssh/id_rsa ~/.ssh/id_rsa.pub  adminUsername@$MASTER:~/.ssh
toni@tonipc:~$ ssh adminUsername@$$MASTER
```

Una vez conectados a master, haremos:

```console
[adminUsername@master ~]$ sudo yum install epel-release -y
[adminUsername@master ~]$ sudo yum install ansible git -y
[adminUsername@master ~]$ sudo sed '/host_key_checking/s/^#//g' -i /etc/ansible/ansible.cfg
[adminUsername@master ~]$ git clone https://github.com/toninoes/devopsunirp2.git
[adminUsername@master ~]$ cd devopsunirp2/ansible/
[adminUsername@master ~]$ ./deploy.sh
PLAY [Hacerlos en todos los hosts] *********************************************

TASK [Gathering Facts] *********************************************************
ok: [worker01]
ok: [nfs]
ok: [master]

TASK [all : Antes de actualizar todas las máquinas] ****************************
changed: [nfs]
changed: [worker01]
changed: [master]
...
...
...
PLAY [Hacerlo en master] ***********************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [master]

TASK [app : Copiar fichero de la aplicacion] ***************************************************************************************************************************
changed: [master]

TASK [Deploy application] **********************************************************************************************************************************************
changed: [master]

PLAY RECAP *************************************************************************************************************************************************************
master                     : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

...y trás un rato estará todo desplegado.

## Verificaciones

Para verificar que los nodos están Ready:

```console
[root@master adminUsername]# kubectl get nodes
NAME       STATUS   ROLES                  AGE   VERSION
master     Ready    control-plane,master   46m   v1.21.2
worker01   Ready    <none>                 46m   v1.21.2
[root@master adminUsername]#
[root@master adminUsername]#
[root@master adminUsername]#
[root@master adminUsername]# kubectl get pods -A -o wide
NAMESPACE            NAME                                       READY   STATUS    RESTARTS   AGE   IP               NODE       NOMINATED NODE   READINESS GATES
calico-system        calico-kube-controllers-7f58dbcbbd-r7lr4   1/1     Running   0          47m   192.169.219.65   master     <none>           <none>
calico-system        calico-node-gmkbg                          1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
calico-system        calico-node-hzgxf                          1/1     Running   0          47m   192.168.1.111    worker01   <none>           <none>
calico-system        calico-typha-76569fffb4-6bj84              1/1     Running   0          46m   192.168.1.111    worker01   <none>           <none>
calico-system        calico-typha-76569fffb4-gcj7d              1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
default              jenkins-74c7d654c9-hjl8r                   1/1     Running   0          18m   192.169.5.3      worker01   <none>           <none>
haproxy-controller   haproxy-ingress-65c5db48c8-68mj7           1/1     Running   0          47m   192.169.5.1      worker01   <none>           <none>
haproxy-controller   ingress-default-backend-78f5cc7d4c-kqzcr   1/1     Running   0          47m   192.169.5.2      worker01   <none>           <none>
kube-system          coredns-558bd4d5db-29dt8                   1/1     Running   0          47m   192.169.219.66   master     <none>           <none>
kube-system          coredns-558bd4d5db-6q4xh                   1/1     Running   0          47m   192.169.219.67   master     <none>           <none>
kube-system          etcd-master                                1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
kube-system          kube-apiserver-master                      1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
kube-system          kube-controller-manager-master             1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
kube-system          kube-proxy-ck6p6                           1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
kube-system          kube-proxy-xlcsn                           1/1     Running   0          47m   192.168.1.111    worker01   <none>           <none>
kube-system          kube-scheduler-master                      1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
tigera-operator      tigera-operator-86c4fc874f-ktfzf           1/1     Running   0          47m   192.168.1.110    master     <none>           <none>
[root@master adminUsername]#
[root@master adminUsername]#
[root@master adminUsername]# kubectl get pods
NAME                       READY   STATUS    RESTARTS   AGE
jenkins-74c7d654c9-hjl8r   1/1     Running   0          21m
```

Vemos con el get pods que nuestro jenkins está corriendo. Y ahora los eventos que han sucedido en nuestro cluster:

```console
[root@master adminUsername]# kubectl get events
LAST SEEN   TYPE     REASON                    OBJECT                          MESSAGE
23m         Normal   Scheduled                 pod/jenkins-74c7d654c9-hjl8r    Successfully assigned default/jenkins-74c7d654c9-hjl8r to worker01
22m         Normal   Pulling                   pod/jenkins-74c7d654c9-hjl8r    Pulling image "jenkins/jenkins:lts"
22m         Normal   Pulled                    pod/jenkins-74c7d654c9-hjl8r    Successfully pulled image "jenkins/jenkins:lts" in 27.992273494s
22m         Normal   Created                   pod/jenkins-74c7d654c9-hjl8r    Created container jenkins
22m         Normal   Started                   pod/jenkins-74c7d654c9-hjl8r    Started container jenkins
23m         Normal   SuccessfulCreate          replicaset/jenkins-74c7d654c9   Created pod: jenkins-74c7d654c9-hjl8r
23m         Normal   ScalingReplicaSet         deployment/jenkins              Scaled up replica set jenkins-74c7d654c9 to 1
52m         Normal   NodeHasSufficientMemory   node/master                     Node master status is now: NodeHasSufficientMemory
52m         Normal   NodeHasNoDiskPressure     node/master                     Node master status is now: NodeHasNoDiskPressure
52m         Normal   NodeHasSufficientPID      node/master                     Node master status is now: NodeHasSufficientPID
52m         Normal   Starting                  node/master                     Starting kubelet.
52m         Normal   NodeHasSufficientMemory   node/master                     Node master status is now: NodeHasSufficientMemory
52m         Normal   NodeHasNoDiskPressure     node/master                     Node master status is now: NodeHasNoDiskPressure
52m         Normal   NodeHasSufficientPID      node/master                     Node master status is now: NodeHasSufficientPID
52m         Normal   NodeAllocatableEnforced   node/master                     Updated Node Allocatable limit across pods
52m         Normal   RegisteredNode            node/master                     Node master event: Registered Node master in Controller
52m         Normal   Starting                  node/master                     Starting kube-proxy.
51m         Normal   NodeReady                 node/master                     Node master status is now: NodeReady
51m         Normal   Starting                  node/worker01                   Starting kubelet.
51m         Normal   NodeHasSufficientMemory   node/worker01                   Node worker01 status is now: NodeHasSufficientMemory
51m         Normal   NodeHasNoDiskPressure     node/worker01                   Node worker01 status is now: NodeHasNoDiskPressure
51m         Normal   NodeHasSufficientPID      node/worker01                   Node worker01 status is now: NodeHasSufficientPID
51m         Normal   NodeAllocatableEnforced   node/worker01                   Updated Node Allocatable limit across pods
51m         Normal   RegisteredNode            node/worker01                   Node worker01 event: Registered Node worker01 in Controller
51m         Normal   Starting                  node/worker01                   Starting kube-proxy.
51m         Normal   NodeReady                 node/worker01                   Node worker01 status is now: NodeReady
```
