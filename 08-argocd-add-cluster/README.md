## Adding a new Kubernetes cluster to ArgoCD
<br>
The first step of adding a new kubernetes cluster to ArgoCD is creating a service account.
<br>
The service account is responsible for deploying the applications in this cluster, it must have the necessary access into the new cluster, it can be an admin.
<br>
I'm using kind, and the following commands should run on a new VM where a new kind kubernetes cluster was created.
<br>

    kubectl create sa new-cluster-sa
    kubectl get sa

<br>
Now we need to bind the cluster-admin clusterrole of the new kubernetes cluster to this service account, because it needs to have the necessary access to this cluster.
<br>

    kubectl get clusterrole cluster-admin
    NAME            CREATED AT
    cluster-admin   2025-02-04T10:48:05Z

    kubectl create clusterrolebinding argocd-cluster-binding--clusterrole=cluster-admin --serviceaccount=default:new-cluster-sa
    clusterrolebinding.rbac.authortzation.k8s.io/argocd-cluster-binding created

Now the new service account **new-cluster-sa** that we created has admin permissions.
<br>

    kubectl auth can-i create pods --as system:serviceaccount:default:new-cluster-sa
    yes
    kubectl auth can-i delete pods --as system:serviceaccount:default:new-cluster-sa
    yes
    kubectl auth can-i delete deployments --as system:serviceaccount:default:new-cluster-sa
    yes

<br>
In the new versions of Kubernetes there is a change that doesn't autocreate the secret when you create the service account, because of that if you want to have a new token for your service account, you need to create it manually.
<br>

    kubectl create token new-cluster-sa
    output_of_the_generated_token

We need to apply this file **08-argocd-add-cluster/add-cluster/add-cluster-manifest/add-cluster.yaml** to the ArgoCD environment (Where ArgoCD is deployed).
<br>

    kubectl apply -f 08-argocd-add-cluster/add-cluster/add-cluster-manifest/add-cluster.yaml

Now if you run **argocd cluster list** you will see that the second cluster was added and the status is unknown.
<br>
The status is unknown because a application is not deployed on the new cluster yet.
<br>

    kubectl apply -f 08-argocd-add-cluster/app-2.yaml

On the new kubernetes cluster run
<br>

    kubectl get all -n external

Using Terraform to add a new kubernetes cluster to ArgoCD
<br>
First delete the manually added kubernetes cluster to ArgoCD
<br>
In **08-argocd-add-cluster/add-cluster/add-cluster-using-terraform** run
<br>

    terraform init
    terraform fmt
    terraform validate
    terraform plan
    terraform apply --auto-approve
    kubectl apply -f 08-argocd-add-cluster/app-3.yaml
    terraform destroy --auto-approve


## Tracking and deployment strategies
<br>
Using helm ArgoCD application the targetRevision is different then the git target revision.
<br>
**helm**
<br>
If we are using an application that its source is helm, the choices are:
<br>
We can use a specific chart version like 1.16.1
A range 1.* || 1.2.*
<br>
latest version of a chart *
<br>
1.* translates to >= 1.0.0 < 2.0.0
<br>
1.2.* translates to >=1.2.0 < 1.3.0
<br>
* translates to latest version
<br>
**git**
<br>
If we are using an application that its source is git, the choices are:
<br>
Using a symbolic reference like HEAD or branch name.
<br>
If a branch name or a symbolic reference is specified, ArgoCD will continually compare LIVE state against the resource manifest defined at the tip of the specified branch.
<br>
The symbolic reference points to the latest commit.
<br>
We can use a tag as well.
<br>
If a tag is specified the manifest at the specified git tag will be used to performed the SYNC comparison, this provides some advantages over branch tracking and that a tag is considered more stable.
<br>
To redeploy an application the user uses git to change the manifest of a tag by retagging it to a different commit, ArgoCD will detect the new meaning of the tag when performing the comparison.
<br>
We can use a commit as well.
<br>
If a commit a specify the app is effectively pinned to the manifest defined at the specified commit. This is the most restrictive of the techniques and is typically used to control Prod environments.