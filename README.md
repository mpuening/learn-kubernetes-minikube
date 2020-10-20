# Learn Kubernetes with Minikube

This project contains my notes that I took as I learned Kubernetes with Minikube.

To review Kubernetes:

* A *deployment* is a metaphor for an application or service. It is a collection of resources 
  or references. Resources can be a container, application, set of containers or a 
  set of pods.
* A *pod* is an instance of a container. A deployment contains one or more pods. The 
  simplest deployment contains a single pod with no redundancy.
* A *service* exposes resources to the outside world or other resources. The various 
  types are ClusterIP (internal/private), NodePort (external IP), or LoadBalancer (also 
  external IP). The cluster needs help from the host (minikube) to expose IPs.

## Installation of Minikube

Here a link to the Kubernetes site for general installation instructions:

```
https://kubernetes.io/docs/tasks/tools/install-minikube/
```

However, what I did was the following:

```
brew install hyperkit

curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit \ && sudo install -o root -g wheel -m 4755 docker-machine-driver-hyperkit /usr/local/bin/
```

And then...

```
brew install kubernetes-cli

brew install minikube
```

To create, start, stop, and view a cluster, run the following commands:

```
minikube start
minikube status
minikube stop
minikube dashboard
minikube delete
 ```
 
 Note that creating a cluster for the first time is a lengthy process (> 10 minutes).
 After that, starting a cluster is just a couple of minutes.
 
 The `status` command results may look like this:
 
 ```
$ minikube status
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```
 
The `dashboard` command should open a browser at the following link:
 
 ```
http://127.0.0.1:63799/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
 ```

The `dashboard` is a nifty web application to easily visualize what is in the cluster. 
For example:

* Cluster Information (Namespaces, Nodes, Persistent Volumes, Storage Classes)
* Cluster Services and Configuration
* Workloads
* Discovery and Load Balancing

## Tour of an Empty Kubernetes Cluster

Here are some `kubectl` commands to view information from the command line:

```
kubectl version --short
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get events
kubectl config view
```

## Deploying Docker Container to Kubernetes

Here is a (deprecated) command to deploy a docker container to Kubernetes

```
kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.4 --port=8080
```

The output of the command should indicate that the command was successful:

```
deployment.apps/hello-minikube created
```

In the `minikube dashboard` you should see:

* `hello-minikube` Pod deployed in the default Node
* `hello-minikube` Deployment

If you run some of the `kubectl` commands, you'll see similar information:

```
$ kubectl get deployments
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
hello-minikube   1/1     1            1           3m19s
```

```
$ kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
hello-minikube-5688c64fd7-kgmpq   1/1     Running   0          3m51s
```

To expose the application outside of the cluster:

```
kubectl expose deployment hello-minikube --type=NodePort
```

The output of the command should indicate the service was created:

```
service/hello-minikube exposed
```

`Minikube` is responsible for the IP address of the service to the outside world. To 
see the URL to access the access, you can run this command:

```
minikube service hello-minikube --url
```

You might see output as follows:

```
http://192.168.64.3:30439
```

An example curl command might be:

```
curl $(minikube service hello-minikube --url)
```

To view existing services, you can run the following command:

```
kubectl get services
```

You will see some similar to the following:

```
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-minikube   NodePort       10.98.199.123   <none>        8080:30439/TCP   13m
kubernetes       ClusterIP      10.96.0.1       <none>        443/TCP          80m
```

To delete the deployment, run the following command:

```
kubectl delete deployment hello-minikube
```

The output of the command should be as follows:

```
deployment.apps "hello-minikube" deleted
```

You should now now see any information about the `hello-minikube` deployment if you 
run the `kubectl` commands or view the `dashboard`.

To delete the `hello-minikube` service, you would run this command:

```
kubectl delete service hello-minikube
```

The output of the command should indicate the service was deleted:

```
service "hello-minikube" deleted
```

The `dashboard` and `kubectl` commands should show nothing about the `hello-minikube` 
deployment and service.
 
## Deploying Hello World Deployment and Load Balancer Service

Here are the commands to deploy a simple `Hello World` Node app to test your cluster:

```
kubectl create deployment hello-node --image=heroku/nodejs-hello-world
```

The output of the command should indicate that the deployment was created:

```
deployment.apps/hello-node created
```

In the `minikube dashboard` you should see:

* `hello-node` Pod deployed in the default Node
* `hello-node` Deployment

If you run some of the `kubectl` commands, you'll see similar information:

```
$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   0/1     1            0           6m14s
```

```
$ kubectl get pods
NAME                          READY   STATUS              RESTARTS   AGE
hello-node-7676b5fb8d-2ckd4   0/1     ContainerCreating   0          7m24s
```

Next, you will want to expose that deployment as a service. For the LoadBalancer to
work, you need to run the `minikube tunnel` command in a separate terminal window:

```
minikube tunnel
```

That command will ask for your password. If you don't run the tunnel, the service will 
end up in a pending state waiting to get an external IP address.

Here is the command to create the service:

```
kubectl expose deployment hello-node --type=LoadBalancer --port=3000
```

The output of the command should indicate that the service was exposed:

```
service/hello-node exposed
```

The `dashboard` should show a new `hello-node` entry on the Services page.

You can see similar information from the command:

```
kubectl get services
```

which will show:

```
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)          AGE
hello-node   LoadBalancer   10.106.227.163   10.106.227.163   8080:31808/TCP   27s
kubernetes   ClusterIP      10.96.0.1        <none>           443/TCP          6h53m
```

If you see that the external IP address is `<pending>` as shown below, check that
the `minikube tunnel` process is running. Try `minikube tunnel --cleanup` if necessary.

```
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node       LoadBalancer   10.101.77.250   <pending>     8080:30334/TCP   65m
kubernetes       ClusterIP      10.96.0.1       <none>        443/TCP          90m
```

The `minikube` command to show the external URL for the service is as follows:

```
minikube service hello-node --url
```

The output might be as follows:

```
http://192.168.64.3:30334
```

Putting this URL in the browser should show `Hello World!`

To delete this node app, run these commands:

```
kubectl delete deployment hello-node
kubectl delete service hello-node
```

The `dashboard` and `kubectl` commands should show nothing about the `hello-node` 
deployment and service.

## Deploying the Tomcat Server With MyApp using a Deployment File

In this example, we are following the example from this URL:

```
https://github.com/LevelUpEducation/kubernetes-demo
```

In the `myapp-deployment` directory, I created/copied the `deployment.yml` which defines
the Tomcat Deployment specification. The file tells us the kind of file it is (Deployment),
its name (myapp-deployment), the image to deploy (myapp:latest), two instances and the port to
expose (8080). The image default registry is the public docker hub.

If you want to follow along, you need to create the docker image. From the `myapp-deployment`
run these commands to build the image we are using:

```
eval $(minikube docker-env)
sh ./build-image.sh
```

The first command redirects your environment to reference the `docker` daemon that `minikube`
uses. Also, note that in the deployment.yml file, we have the `imagePullPolicy: Never` policy set.
This way, the deployment won't try to find out test container in the main registry.

Here is the command to `apply` this deployment (assuming you are in top level directory):

```
kubectl apply -f ./myapp-deployment/deployment.yml
```

The output of the command should indicate that the deployment was successful.

```
deployment.apps/myapp-deployment created
```

As before, confirm you can see the deployment resources in the `dashboard` or `kubectl` 
commands.

And to expose the deployment as a service:

```
kubectl expose deployment myapp-deployment --type=NodePort
```

Again, you can verify the service in the `dashboard` or `kubectl`  commands.

To find the URL to my app, use this command:

```
minikube service myapp-deployment --url
```

A handy `minikube` command to launch the browser with the URL is this:

```
minikube service myapp-deployment
```

The Tomcat example URI is located at `/examples/index.html`.

## More Interesting `kubectl` Commands

The cheatsheet for `kubectl` is here:

```
https://kubernetes.io/docs/reference/kubectl/cheatsheet/
```

Here are some I tried:

```
kubectl get deployments
kubectl describe deployments
kubectl describe deployments myapp-deployment

kubectl get pods
kubectl describe pod myapp-deployment-7b9d6d8f4d-npflc

kubectl scale --replicas=2 deployment/myapp-deployment

kubectl port-forward myapp-deployment-7b9d6d8f4d-npflc 5000:6000

kubectl attach myapp-deployment-7b9d6d8f4d-npflc

kubectl exec -it myapp-deployment-7b9d6d8f4d-npflc bash

kubectl label pods myapp-deployment-7b9d6d8f4d-npflc healthy=true
```

### Scaling

When multiple instances of the pod are running, you need the load balancer service. 
You can actually have multiple services on the deployment if you give them different 
names as follows (don't forget to run the tunnel in a separate window):

```
minikube tunnel

kubectl expose deployment myapp-deployment --type=LoadBalancer --port=8080 --target-port=8080 --name myapp-load-balancer
```

And to open the browser with the new service (but difference port):

```
minikube service myapp-load-balancer
```

### Working with Deployments

With Kubernetes, you can:

* Create new deployments
* Update existing deployments
* Apply rolling updates
* Rollback to a previous version
* Pause and resume deployments
* Delete deployments

For example:

```
kubectl get deployments
kubectl rollout status deployment myapp-deployment
kubectl set image deployment/myapp-deployment myapp=myapp:1.1.0
kubectl rollout history deployment/myapp-deployment
```

To apply a change:

```
kubectl apply -f ./myapp-deployment/deployment.yml
```

To delete a deployment:

```
kubectl delete -f ./myapp-deployment/deployment.yml
```

### Working with Labels and Selectors

To label a node:

```
kubectl label node minikube laptopType=MacBook
```

To verify:

```
kubectl describe node minikube
```

Selectors can be specified in `deployment.yml` to only apply to certain resources. 
For example, see `nodeSelector` in the deployment file.

### Health Checks

Deployments can have `startupProbes`, `livenessProbe` and `readinessProbe` specifications
in the deployment file that kubernetes will use to check the health the deployment
both at start up and while the application is running.

The readiness probe is used to know when a Container is ready to start accepting traffic.

The liveness probe is used to know when to restart a container.

The startup probe is used to know when a Container application has started. Note: if this
probe is configured, the liveness and readiness checks are disabled until it succeeds, 
making sure those probes do not interfere with the startup procedure.

Note for March, 2020: It seems as though there are bugs in Kubernetes that make the 
probes problematic. It is common for the HTTP probes receive timeout errors due to
problems reading headers.  That is why they are commented out in the `deployment.yml` 
file.

## Config Maps (and Secrets)

Config maps are the environment aspect of Kubernetes. With this feature, you can
make available both files and environment variables to the pods, and the applications
can even be notified when updates are made to them.

In the Spring Boot eco-system, it seems to be the convention to create a YAML file
to be loaded during start up. Spring makes available starters to make it trivial to 
consume the files.

The following is an example command to make a secret:

```
kubectl create secret generic svc-credentials --from-literal=username=username --from-literal=password=password
```

The following is an example command to make a config map from a yml file:

```
kubectl create configmap my-app-config --from-file=/path/to/my-app-config.yml
```

However, one can also use a specification file, as I have in the `spring-boot-config`
directory. To deploy it, execute the following:

```
kubectl apply -f ./spring-boot-config-map/config-map.yml
```

See vault techniques for secrets.

See the Spring Boot Application below for usage of the config map.

## Persistent Volumes

A persistent volume is storage that can be assigned to a pod, and survives after the 
pod is deleted.

In the `spring-boot-persistent-volume` directory there are two specification files 
to create a persistent volume and its claim. To create them, use these commands:

```
kubectl apply -f ./spring-boot-persistent-volume/persistent-volume-claim.yml
kubectl apply -f ./spring-boot-persistent-volume/persistent-volume.yml
```

To verify, that the storage is hooked up after being claimed (which is done below with 
the spring-boot-deployment app), you can log into one of the pods as follows:

```
kubectl exec --stdin --tty  spring-boot-deployment-566fbcd878-p6p57 -- /bin/bash
```

Create a file in the `/tmp/logs` directory as follows:

```
cat > /tmp/logs/pv-test.log << EOF
Hey, this is a test.
EOF
```

Then log into minikube as follows and check the persistent volume to see if you see 
the file. The directory name can be found in the `minikube dashboard`.

```
minikube ssh
cd /tmp/hostpath-provisioner/pvc-735b764d-f24e-43de-a6af-edbe621fb52f
ls
```

See the Spring Boot Application below for usage of the persistent volume.

## Spring Boot Application Deployment Using a Local Registry

In the `spring-boot-deployment` directory is a Spring Boot application designed to
be built with a buildpack. Support for this has been added to Spring Boot 2.3.

To build the application, run this command from the spring-boot-deployment directory:

```
./mvnw spring-boot:build-image
```

To verify that the image is available, run this command:

```
docker images | grep spring-boot-app
```

To run the image, use this command:

```
docker run -d -p 8080:8080 spring-boot-app:latest
```

Using your browser, visit: `http://localhost:8080/actuator/info`

### Kubernetes Deployment

To deploy the Spring Boot Application to Kubernetes, we have a `deployment.yml` file 
that is very similar to the one used to deploy the Tomcat application.

However, the image we want to deploy is not in the Minikube registry; it is in your
usual local docker registry.

Below are instructions I got from this page:

```
https://minikube.sigs.k8s.io/docs/tasks/registry/insecure/
```

To make the image available to Minikube, you need a registry as a go-between. So you need 
this add-on:

```
minikube addons enable registry
```

Next, you want to start minikube with command:

```
minikube start --insecure-registry "10.0.0.0/24"
```

Once started, you need to map ports from the docker virtual machine to the Minikube
virtual machine. Use this command (running in its own terminal window):

```
docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"
```

To push the image over to go-between registry, run these commands:

```
docker tag spring-boot-app:latest localhost:5000/spring-boot-app:latest
docker push localhost:5000/spring-boot-app:latest
```

To apply the application to Kubernetes, run (and note the localhost:5000 reference in `deployment.yml`):

```
kubectl apply -f ./spring-boot-deployment/deployment.yml
```

and to expose the application:

```
minikube tunnel

kubectl expose deployment spring-boot-deployment --type=LoadBalancer --port=8080 --target-port=8080 --name spring-boot-load-balancer
```

And to open the browser with the new services:

```
minikube service spring-boot-load-balancer
```

## Kubernetes Infrastructure Examples

The `infrastucture` folder contains examples for operating minikube and deploying
infrastructure to kubernetes. Examples include:

* Graylog (with ElasticSearch and MongoDB)
* Mysql
* Hashicorp Vault

TODO: Write more documentation about the scripts in each example, although they mainly 
contain commands from this file.
