# Example 2 #

This example shows the interaction between 2 components using a RESTFUL(Not so full) API.
Basically the client application(customer) access the server app(bartender) through a service by using the vip address the it's specific port.

So, when the client app invokes the server app the vip handles the request and redirects the it to one of the available instances.

The basic tutorial used to implement this test is available [here](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/)

### Roles ###

> Customer - Orders a drink to the bartender and shows to everybody!

> Bartender - Provides the drinks menu and prepares the drinks.

Why? I'm drinking now...

## Getting ready ##

Installing your environment at the base node:

```shell
$ cd /vagrant/examples/example2-service_integration/
$ ./install.sh
```

## Installing the Bartender ##

Execute the installation of the deployment and the service from a kube node

```shell
$ cd /vagrant/examples/example2-service_integration/
$ kubectl create -f bartender/deploy.yaml
$ kubectl get pods -o wide
```

And you will see the number of instances of bartenders you have

```shell
NAME                                             READY     STATUS    RESTARTS   AGE       IP            NODE
example2-bartender-deployment-3738030372-jcb96   1/1       Running   0          1d        172.30.14.2   kube1.local
```
Now we need to create the service

```shell
$ kubectl create -f bartender/service.yaml
service "example2-bartender-service" created
```

Take a look on the service installation and pay atention on the IP it shows, it's important to the next steps:

```shell
$ kubectl describe service example2-bartender-service
Name:                   example2-bartender-service
Namespace:              default
Labels:                 <none>
Selector:               app=example2-bartender
Type:                   NodePort
IP:                     10.254.153.161
Port:                   <unset> 7000/TCP
NodePort:               <unset> 30210/TCP
Endpoints:              172.30.14.2:7000
Session Affinity:       None
No events.
```
Now we can curl it:

```shell
$ curl http://kube1.local:30210/menu|python -m json.tool
  
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   160  100   160    0     0  10033      0 --:--:-- --:--:-- --:--:-- 10666
[
    {
        "id": 1,
        "name": "Caipirinha",
        "price": 10
    },
    {
        "id": 2,
        "name": "CaipiSake",
        "price": 8.1
    },
    {
        "id": 3,
        "name": "Budweiser",
        "price": 0.3
    },
    {
        "id": 4,
        "name": "Heineken",
        "price": 3.2
    }
]

```
The service is ok, it's the standard response.

## Installing the Customer ##

Basically we need to execute the same steps but to the customer application... 

```shell
$ cd /vagrant/examples/example2-service_integration/
$ kubectl create -f customer/deploy.yaml
$ kubectl create -f customer/service.yaml
```

Let's check the cluster

```shell
$ kubectl get all
NAME                                   DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/example2-bartender-deployment   1         1         1            1           12m
deploy/example2-customer-deployment    1         1         1            1           27s

NAME                             CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
svc/example2-bartender-service   10.254.153.161   <nodes>       7000:30210/TCP   9m
svc/example2-customer-service    10.254.92.0      <nodes>       7100:30220/TCP   14s
svc/kubernetes                   10.254.0.1       <none>        443/TCP          1d

NAME                                          DESIRED   CURRENT   READY     AGE
rs/example2-bartender-deployment-3738030372   1         1         1         1d
rs/example2-customer-deployment-3853176918    1         1         1         1d

NAME                                                READY     STATUS    RESTARTS   AGE
po/example2-bartender-deployment-3738030372-jcb96   1/1       Running   0          1d
po/example2-customer-deployment-3853176918-2wjc2    1/1       Running   0          1d
```

Let's curl it!

```shell
$ curl http://kube1.local:30220|python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    39  100    39    0     0   1680      0 --:--:-- --:--:-- --:--:--  1695
{
    "id": 1,
    "name": "Caipirinha",
    "price": 10
}
```
I love caipirinha!

## What did it do? ##

On the [custumer](https://github.com/marceluxvk/vagrant-k8s-ha/blob/master/examples/example2-service_integration/customer/src/main.go) file you can see at the init method that the application gets 2 environment variables

> EXAMPLE2_BARTENDER_SERVICE_SERVICE_HOST: Variable that has the ip address of the service

> EXAMPLE2_BARTENDER_SERVICE_SERVICE_PORT: Variable that has the port value for the bartender service

Here is the piece of code you need understand:
```golang

func init() {
	service = os.Getenv("EXAMPLE2_BARTENDER_SERVICE_SERVICE_HOST") + ":" + os.Getenv("EXAMPLE2_BARTENDER_SERVICE_SERVICE_PORT")
}
```

So, let's check the value of these variables on a running container:

```shell
$ kubectl get pods -o wide
NAME                                             READY     STATUS    RESTARTS   AGE       IP            NODE
example2-bartender-deployment-3738030372-jcb96   1/1       Running   0          1d        172.30.14.2   kube1.local
example2-customer-deployment-3853176918-2wjc2    1/1       Running   0          1d        172.30.36.2   kube2.local
```

I can see that the customer pod is running on the kube2.local, so I can go there and check the environment variables.

```shell
$ docker exec -it <your container id> bash
$ set 
... 
...
EXAMPLE2_BARTENDER_SERVICE_PORT=tcp://10.254.153.161:7000
EXAMPLE2_BARTENDER_SERVICE_PORT_7000_TCP=tcp://10.254.153.161:7000
EXAMPLE2_BARTENDER_SERVICE_PORT_7000_TCP_ADDR=10.254.153.161
EXAMPLE2_BARTENDER_SERVICE_PORT_7000_TCP_PORT=7000
EXAMPLE2_BARTENDER_SERVICE_PORT_7000_TCP_PROTO=tcp
EXAMPLE2_BARTENDER_SERVICE_SERVICE_HOST=10.254.153.161
EXAMPLE2_BARTENDER_SERVICE_SERVICE_PORT=7000
...
...
```

Let's check the service info on kubernetes

```shell
[vagrant@kube2 example2-service_integration]$ kubectl describe service example2-bartender-service
Name:                   example2-bartender-service
Namespace:              default
Labels:                 <none>
Selector:               app=example2-bartender
Type:                   NodePort
IP:                     10.254.153.161
Port:                   <unset> 7000/TCP
NodePort:               <unset> 30210/TCP
Endpoints:              172.30.14.2:7000
Session Affinity:       None
No events.
``` 

Now it's clear for us that the client application(customer) is configured to send the requests to the service by using the service's ip and port. All request will be balanced through the available instances of application.

