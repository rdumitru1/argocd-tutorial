To login with argocd cli run **argocd login [cluster_hostname] --insecure --grpc-web**
Under **spec/destination** we are telling Argo where to deploy the application
**/spec/destination/namespace** the namespace where the application is deployed
**/spec/destination/server** the server on which the application should be deployed
To get the server run **argocd cluster list --grpc-web**
    argocd cluster list --grpc-web
    SERVER                          NAME        VERSION  STATUS      MESSAGE  PROJECT
    https://kubernetes.default.svc  in-cluster  1.27     Successful
The server name **https://kubernetes.default.svc** is because ArgoCD has a controller that lives in the default kubernetes cluster, in current cluster.
ArgoCD is able to connect to remote clusters as well.
**https://kubernetes.default.svc** Is the server name/address of our current and default kubernetes cluster.
<br>
The **project:** consists of multiple applications. An application should be in a **project:**, so it isnecessary to define a project name for our application
<br>
<br>

    source:
      helm:
        releaseName: application-from-helm
      path: 03-argocd-applications/helm/nginx
      repoURL: https://github.com:rdumitru1/argocd-tutorial.git
      targetRevision: main
**helm:** let you add options regarding helm
**repoUrl:** is the url of our git repository that we want to use as a source
**path:** the path that I want to use as the source, as the group of manifests. The path of the helm charts that I want to deploy
**targetRevision:** We can use a branch name, or a commit id or a tag name.
