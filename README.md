# Kubernetes Hight Availability Enabled Environment #

This is a easy fast guide for enable everybody to create their own kubernetes with hight availability configuration.

The hosts are provisioned using [vagrant](https://docs.docker.com/) and [virtual box](https://www.virtualbox.org/wiki/Downloads), so if you wanna try this module you must install theses both tools.

You can modify the virtualization platform by changing the [Vagrantfile](https://github.com/marceluxvk/vagrant-k8s-ha/blob/master/Vagrantfile) according [this](https://www.vagrantup.com/docs/providers/) documentation.

## Where Does this environment come from? ##

There are 3 interesting tutorials on the vendors sites:
- [kubernetes for CENTOS](https://kubernetes.io/docs/getting-started-guides/centos/centos_manual_config/)
- [kubernetes cluster tutorial](https://kubernetes.io/docs/admin/high-availability/)
- [etcd cluster](https://github.com/coreos/etcd/blob/master/Documentation/op-guide/clustering.md)

The etcd server is running as a single instance because it's not the main target of this test but their site have very useful informations to help you run it in a multi-instance mode.

So, every request we send to kubernates will be balanced between the available nodes to be redirect to one of the available kube-apiservers.
![teste](https://kubernetes.io/images/docs/ha.svg)



