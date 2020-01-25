### Neo CI Cluster

CI Cluster infrastructure as code for NEO.

Tools
- EKS
- Helm
- Jenkins X

Nice Tools
- Kubens/Kubectx

Monitoring Tools
- Prometheus
- Grafana

AWS Resources
- EKS Cluster : neo-eks
- EC2 Instance : DevOps Tower (Management Server)
- S3 Buckets : devops-tower-terraform , neo-ci-cluster-terraform
- VPC/Subnets/AutoScaling Group/ALB/Route53[zaksnotes.com(personal domain)]


### Known Issues :

* As shown here, AWS pushes few admission controllers classes everytime and they never did for the admission controller PersistentVolumeLabel. With this AC, EKS will automatically assign zones to PVs, as mentioned here : https://kubernetes.io/docs/setup/best-practices/multiple-zones/ and here https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html. I tried to alter the StorageClass kubernetes object but it didn't help.

* I had to grant serviceaccount:default permissions to the kube-system, something is wrong with Terraform Helm provider which doesn't use the ClusterRoleBinding and the ServiceAccount "tiller" that I have it executed in my Terraform Apply.

#### before
kubectl auth can-i get cm --as="system:serviceaccount:kube-system:default" > no
kubectl auth can-i get cm --as="system:serviceaccount:kube-system:tiller" > yes

#### after
kubectl auth can-i get cm --as="system:serviceaccount:kube-system:default" > yes
kubectl auth can-i get cm --as="system:serviceaccount:kube-system:tiller" > yes
