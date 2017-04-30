## Example 1 ##

This example just shows the hostname of the docker container instance running th

### Executing ###

Installing your environment:

```shell
cd /vagrant/examples/example1-nodeid
sh install.sh
kubectl create -f deploy.yaml
kubectl create -f service.yaml
```

Execute the simple test:
```shell
$ curl http://kube1.local:30200
The hostname is: example1-deployment-998556453-hqp2n

$ curl http://kube2.local:30200
The hostname is: example1-deployment-998556453-hqp2n
```
As you can see, both request have the same output, this is because the kube-proxy is doing their job, exposing the service port and redirecting the request to the available node.

## Scaling the service ##

To scale your pod just run: 

```shell
$ kubectl scale deployment example1-deployment --replicas=10
```

Now you can see we have 10 instances of the same service running:
```shell
[vagrant@kube1 example1-nodeid]$ kubectl get pods -o wide
NAME                                  READY     STATUS    RESTARTS   AGE       IP            NODE
example1-deployment-995804533-63vlp   1/1       Running   0          1d        172.30.14.3   kube1.local
example1-deployment-995804533-7cpjc   1/1       Running   0          1d        172.30.36.3   kube2.local
example1-deployment-995804533-b34wb   1/1       Running   0          1d        172.30.14.6   kube1.local
example1-deployment-995804533-g8hnq   1/1       Running   0          1d        172.30.36.5   kube2.local
example1-deployment-995804533-p47lh   1/1       Running   0          1d        172.30.14.2   kube1.local
example1-deployment-995804533-slbcq   1/1       Running   0          1d        172.30.14.4   kube1.local
example1-deployment-995804533-v1xtd   1/1       Running   0          1d        172.30.14.5   kube1.local
example1-deployment-995804533-vbxht   1/1       Running   0          1d        172.30.36.4   kube2.local
example1-deployment-995804533-wr0gj   1/1       Running   0          1d        172.30.36.2   kube2.local
example1-deployment-995804533-z02t6   1/1       Running   0          1d        172.30.36.6   kube2.local
```

Let's curl the things:

```shell
[vagrant@kube1 example1-nodeid]$ while true;do curl http://kube1.local:30200;done
The hostname is: example1-deployment-995804533-g8hnq
The hostname is: example1-deployment-995804533-63vlp
The hostname is: example1-deployment-995804533-v1xtd
The hostname is: example1-deployment-995804533-p47lh
The hostname is: example1-deployment-995804533-v1xtd
The hostname is: example1-deployment-995804533-7cpjc
The hostname is: example1-deployment-995804533-vbxht
The hostname is: example1-deployment-995804533-wr0gj
The hostname is: example1-deployment-995804533-z02t6
The hostname is: example1-deployment-995804533-7cpjc
The hostname is: example1-deployment-995804533-slbcq
The hostname is: example1-deployment-995804533-7cpjc
The hostname is: example1-deployment-995804533-wr0gj
The hostname is: example1-deployment-995804533-p47lh
The hostname is: example1-deployment-995804533-wr0gj
The hostname is: example1-deployment-995804533-b34wb
The hostname is: example1-deployment-995804533-7cpjc
The hostname is: example1-deployment-995804533-wr0gj
The hostname is: example1-deployment-995804533-v1xtd
The hostname is: example1-deployment-995804533-slbcq
The hostname is: example1-deployment-995804533-vbxht
The hostname is: example1-deployment-995804533-z02t6
The hostname is: example1-deployment-995804533-z02t6
The hostname is: example1-deployment-995804533-7cpjc
The hostname is: example1-deployment-995804533-63vlp
The hostname is: example1-deployment-995804533-b34wb
The hostname is: example1-deployment-995804533-wr0gj
The hostname is: example1-deployment-995804533-wr0gj
The hostname is: example1-deployment-995804533-slbcq
The hostname is: example1-deployment-995804533-slbcq
The hostname is: example1-deployment-995804533-slbcq
The hostname is: example1-deployment-995804533-p47lh
The hostname is: example1-deployment-995804533-7cpjc

``` 
You can see that the request are been balanced through all nodes and instances of services we have.
