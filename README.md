
### Neo CI Cluster
CI Cluster infrastructure as code for NEO

The choice of the public cloud..
Although I am too close to Oracle Cloud at my current position. I have a good relationshop with AWS, it has been my favorite.

#### Tools
- EKS, Helm, Jenkins X, Terraform, Ansible

#### Nice Tools
- Kubens/Kubectx

#### Monitoring Tools
. Prometheus
. AlertManager
. Grafana

#### AWS Resources :
- EKS Cluster : neo_eks (cluster_name)
- EC2 Instance : DevOps Tower (Management Server)
- S3 Buckets : devops-tower-terraform , neo-ci-cluster-terraform
- VPC/Subnets/AutoScaling Group/ALB/Route53 ( zaksnotes.com ) (personal domain name)

#### Security
I made sure to have a unique VPC for NEO and I divided into 6 subnets. 3 publics and 3 privates. The idea is simple; all the pods that don't need access to the internet are on a private subnet. The Load Balancer is sitting outside listening for incoming traffic and forwarding it to Ingress Controller, therefore our ELB is between the public subnet.

#### The Provisioning of the CI Cluster

After provisioning my CI Cluster using Terraform and putting into practice the idea of infrastructure as code. I installed JX to transcend the next level of automation : CI environments.

```
jx install --provider=eks --default-environment-prefix=neo --no-default-environments --ingress-deployment=nginx-ingress-controller --ingre
s-service=ingress-nginx --domain=zaksnotes.com  --docker-registry=617782583250.dkr.ecr.us-east-2.amazonaws.com/neo/development --skip-ingr
ss --ingress-namespace=ingress-nginx
```

Oh and yes, after my Terraform apply I run a playbook remotely to install ingress controller using Ansible. Ingress Controller is quiet important to setup before moving to JX.

### Continue with Helm

```
helm install stable/grafana --namespace monitoring --set rbac.create=true --set=ingress.enabled=True,ingress.hosts={grafana.zaksnotes.com},persistent_enabled=true
helm install stable/prometheus --namespace monitoring --set rbac.create=true
```

### Setup our Pipelines using JX commands

```
jx create env test --branches=test  --namespace=jx-test --promotion=auto
```
the dev environment is the default environment.

### Known Issues :

* Admission Controllers in Kubernetes are like hidden features that you can enable when starting Kubelet on a given node. AWS deploys few more admission controllers in their Kubernetes product (EKS). The AC that I just realized is missing, is PersistentVolumeLabel, this one can automatically label and manage Persistent Volumes across AZs. More here : https://kubernetes.io/docs/setup/best-practices/multiple-zones/ and here https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html.
I tried to alter the StorageClass kubernetes object but it didn't help.

* I had to grant serviceaccount:default permissions to the kube-system. Something is wrong with Terraform : Helm provider which doesn't use the ClusterRoleBinding and the ServiceAccount "tiller" that I have it present in my Terraform session.

* For some reason the run of the Helm provider and installing its resource Ingress Nginx is not working as it should. I had to incorporate a little hack to continue.

#### before
kubectl auth can-i get cm --as="system:serviceaccount:kube-system:default" > no

kubectl auth can-i get cm --as="system:serviceaccount:kube-system:tiller" > yes

#### after
kubectl auth can-i get cm --as="system:serviceaccount:kube-system:default" > yes

kubectl auth can-i get cm --as="system:serviceaccount:kube-system:tiller" > yes

It's a hack, but more time would allow further investigations.
