# Kubernetes High Availability Enabled Environment #

This test aims to enable everybody to start and test the kubernates high available cluster environment.
All configuration are available to guarantee the well understanding about how to configure and enable a kubernates cluster.

## About the tools ##
The hosts are provisioned using [vagrant](https://docs.docker.com/) and [virtual box](https://www.virtualbox.org/wiki/Downloads), so if you wanna try this module you must install theses both tools.

You can modify the virtualization platform by changing the [Vagrantfile](https://github.com/marceluxvk/vagrant-k8s-ha/blob/master/Vagrantfile) according [this](https://www.vagrantup.com/docs/providers/) documentation.

## Where Does this environment come from? ##

There are 3 diferent sources of information that supports this envirionment. If you wanna understand the details of the configurations and different behaviours you can set on your cluster, please visit:
- [kubernetes for CENTOS](https://kubernetes.io/docs/getting-started-guides/centos/centos_manual_config/)
- [kubernetes cluster tutorial](https://kubernetes.io/docs/admin/high-availability/)
- [etcd cluster](https://github.com/coreos/etcd/blob/master/Documentation/op-guide/clustering.md)

## The BASE node ##

The base node simulates everything else needed to support a production ready and high available kubernetes environment.

### ETCD Configuration ###

The etcd server is running as a single instance once it's not the main target of this test. To find out more information about alternatives cluster configuration and behaviours, please visiti [etcd cluster website](https://github.com/coreos/etcd/blob/master/Documentation/op-guide/clustering.md)

### HAProxy ###
Inside the Base node I installed a HAProxy that works as a LoadBalancer. With this design we have a single entry point for all instances of ***kubernetes-apiserver***.

## Clustering ##

To create a kube HA Cluster you must keep in mind that all **kube-apiserver** requests must by handled by the balancer, that will redirect the request to some available apiserver node.

![teste](https://kubernetes.io/images/docs/ha.svg)

### Configuring the balancer to the kubernetes components ###

Basically, after the cluster and the apiserver configuration the following components must be reconfigured to the balancer insted some specific instance of kube-apiserver:

[/etc/kubernetes/config](https://github.com/marceluxvk/vagrant-k8s-ha/blob/master/cookbooks/kubernetes/files/kube_config)

### Enabling the leader election ###

To enable the leader election the parameter ```--leader-elect``` must be added to the following configuration files:

- [kube-controller-manager](https://github.com/marceluxvk/vagrant-k8s-ha/blob/master/cookbooks/kubernetes/files/controller-manager)
- [kube-scheduler](https://github.com/marceluxvk/vagrant-k8s-ha/blob/master/cookbooks/kubernetes/files/scheduler)

So, if everything is ok, the high available kubernetes cluster is ready to use.


## Usage ##

Firt of all you have to clone this repository and install the vagrant and the virtual box.

### Basic Vagrant Commands ###

Initialize instances:
```shell
vagrant up --provision
```

Listing instance:
```shell
vagrant status
```

Removing instance:
```shell
vagrant destroy
```

Accessing vagrant hosts:
```shell
vagrant ssh <hostname>
```

## Installing and configuring virtual machines ##

To create the nodes you executes:

```shell
vagrant up --provision
```

To list all nodes you have just finished to create run:

```shell
vagrant status
```

There's a issue I have not fixed yet that is the automatically start of the haproxy, so, you need to start it manually.

Access the BASE instance
```shell
vagrant ssh base
```

Starting the haproxy
```shell
sudo systemctl start haproxy
```

## Testing your installation ##

Accessing the node 1
```
vagrant ssh kube1
```

Listing the kubernetes nodes:

```shell
[vagrant@kube1 ~]$ kubectl get nodes
NAME          STATUS    AGE
kube1.local   Ready     1h
kube2.local   Ready     1h
```

Listing everything on your cluster:
```shell
[vagrant@kube1 ~]$ kubectl get all
NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
svc/kubernetes   10.254.0.1   <none>        443/TCP   1h
```

Creating the first basic deployment:
```shell
[vagrant@kube1 ~]$ kubectl create -f /vagrant/examples/
deploy.yaml   service.yaml
[vagrant@kube1 ~]$ kubectl create -f /vagrant/examples/deploy.yaml
deployment "nginx-deploy" created
```

Listing all:
```shell
[vagrant@kube1 ~]$ kubectl get all
NAME                  DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/nginx-deploy   1         1         1            1           14s

NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
svc/kubernetes   10.254.0.1   <none>        443/TCP   1h

NAME                         DESIRED   CURRENT   READY     AGE
rs/nginx-deploy-1447934386   1         1         1         14s

NAME                               READY     STATUS    RESTARTS   AGE
po/nginx-deploy-1447934386-t8lrx   1/1       Running   0          23s
```
Creating first service:
```shell
[vagrant@kube1 ~]$ kubectl create -f /vagrant/examples/service.yaml
service "nginx-service" created
```

Checking the service details:
```shell
[vagrant@kube1 ~]$ kubectl describe svc/nginx-service
Name:                   nginx-service
Namespace:              default
Labels:                 <none>
Selector:               app=nginx
Type:                   NodePort
IP:                     10.254.190.205
Port:                   <unset> 80/TCP
NodePort:               <unset> 30100/TCP
Endpoints:              172.30.36.2:80
Session Affinity:       None
No events.
```
At this point you can see that there's only one instance of service running as endpoint

Testing the kubeproxy:
```shell
curl http://kube1.local:30100
curl http://kube2.local:30100
```
Both commands must return the http request.
After this point your are ready to run your own tests.


## Link ##
> [Workload Resources](https://kubernetes.io/docs/resources-reference/v1.5/)

> [Nginx Ingress Controller](https://github.com/nginxinc/kubernetes-ingress/tree/master/nginx-controller)

> [kubectl-cheatsheet](https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/)
