To login with argocd cli run **argocd login [cluster_hostname] --insecure --grpc-web** <br>

***helm/application-1.yaml***

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: application-from-scratch
    spec:
      destination: # Where the application is deployed
        namespace: default
        server: https://kubernetes.default.svc
      project: default
      source:
        helm:
          releaseName: application-from-helm
          valueFiles:
            - custom-values.yaml
        path: 03-argocd-applications/helm/nginx
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main

Under **spec/destination** we are telling Argo where to deploy the application <br>
- **/spec/destination/namespace** the namespace where the application is deployed <br>
- **/spec/destination/server** the server on which the application should be deployed <br>
<br>

To get the server run **argocd cluster list --grpc-web**

```bash
argocd cluster list --grpc-web
SERVER                          NAME        VERSION  STATUS      MESSAGE  PROJECT
https://kubernetes.default.svc  in-cluster  1.27     Successful
```

The server name **https://kubernetes.default.svc** is because ArgoCD has a controller that lives in the default kubernetes cluster, in current cluster. <br>
ArgoCD is able to connect to remote clusters as well. <br>
**https://kubernetes.default.svc** Is the server name/address of our current and default kubernetes cluster. <br>
<br>
The **project:** consists of multiple applications. An application should be in a **project:**, so it is necessary to define a project name for our application
<br>

**source/helm:** let you add options regarding helm <br>
- **source/helm/releaseName:** The name of the release
- **source/helm/valueFiles:** Reference to a value file

**source/repoUrl:** is the url of our git repository that we want to use as a source <br>
**source/path:** the path that I want to use as the source, as the group of manifests. The path of the helm charts that I want to deploy <br>
**source/targetRevision:** We can use a branch name, or a commit id or a tag name. <br>

***helm/application-2.yaml***

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: sealed-secrets
      namespace: argocd
    spec:
      project: default
      source:
        chart: sealed-secrets
        repoURL: https://bitnami-labs.github.io/sealed-secrets
        targetRevision: 1.16.1
        helm:
          releaseName: sealed-secrets
      destination:
        server: "https://kubernetes.default.svc"
        namespace: default

**spec/source/repoURL:** Here we are using a helm repository intead of a git repository. <br>
**spec/source/chart:** This is the chart name the we want to use from the repository. <br>
**spec/source/targetRevision:** This is the revision/version of the chart. <br>


## Using ***directory*** for plain manifest files. <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: application-directory
    spec:
      destination: # Where the application is deployed
        namespace: directory
        server: https://kubernetes.default.svc
      project: default
      source:
        directory:
          include: "serviceaccount.yaml"
        path: 03-argocd-applications/directoryofmanifests
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main

By changing the **spec/source/path** to an directory containing plain manifests files, argo knows to apply them directly. <br>
**/spec/source/directory** it is optional in the context of plain manifests files. <br>
There are some parameters that directory supports. <br>
- **/spec/source/directory/include: 'some-directory/*'** or **/spec/source/directory/include: 'some-file'** it includes an entire directory or a file. If there is already an application deployed and you add the include parameter it will delete the resources that are already deployed and deploy only the ones specified in the include parameter.
- **/spec/source/directory/include: "{file1.yaml, file2.yaml}"** it includes only the specified files.
- **/spec/source/directory/include: "{*.yml, *.yaml}"** it includes all the files having ***yml*** and ***yaml*** pattern.

- **/spec/source/directory/exlude: 'some-directory/*'** or **/spec/source/directory/include: 'some-file'** it excludes an entire directory or a file.
- **/spec/source/directory/exclude: "{file1.yaml, file2.yaml}"** it excludes only the specified files.
- **/spec/source/directory/exclude: "{*.yml, *.yaml}"** it excludes all the files having ***yml*** and ***yaml*** pattern.

- **/spec/source/directory/recurse: true** enables recursive detection of plain manifests files, by default, directory applications will only include the files from the root of the configured repository/path.
