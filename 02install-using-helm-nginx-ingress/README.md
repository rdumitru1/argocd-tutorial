To install ago using helm with nginx ingress. <br>
Add the Argo helm repo. <br>

    helm repo add argo https://argoproj.github.io/argo-helm
Create the argocd namespace. <br>

    kubectl create ns argocd

Install ArgoCD. <br>

    helm install argocd argo/argo-cd  -n argocd --atomic -f values1.yaml
