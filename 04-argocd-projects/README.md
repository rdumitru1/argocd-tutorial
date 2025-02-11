**projects** provide a logical grouping of applications, which is useful when Argo CD is used by multiple teams. <br>
Each applications must belong to a project and by default each application uses a project called default. <br>
**projects** provide the following features: <br>
- **Restrict what may be deployed** (trusted Git source repositories). You can specify to an application what repo to use and it use the **sourceRepo** block. <br>
  Lets presume that we have **application1**, and I want that my **application1** uses only this repository **https://github.com/rdumitru1/argocd-tutorial.git**. <br>

      sourceRepos:
        https://github.com/rdumitru1/argocd-tutorial.git
  If this application uses another repository, it can't be deployed, so it is allowed to use this repository only. <br>
  This is like a wite list and I can add other repositories as well. <br>
  If I use other repositories than the one specified, it can't be deployed. <br>
  I can use **\!** in front of a repository it means that I can't use this repository. If my application is using this repositories, it can't be deployed. <br>

      sourceRepos:
        !https://github.com/rdumitru1/argocd-tutorial.git
  If I want my application not to use a specific repository and use all other repositories. <br>

      sourceRepos:
        !https://github.com/rdumitru1/argocd-tutorial.git
        '*'

- **Restrict where apps may be deployed to** (destination clusters and namespaces). You can specify the namespace and server where the application will be deployed. <br>
  Deploy a application to any namespace, and any server. <br>

      destination:
        namespace: '*'
        server: '*'
  To deploy the application in the dev namespace and to be able to deploy it to any server. <br>
  All other namespaces are not allowed. <br>
      destination:
        namespace: 'dev'
        server: '*'
  To deploy the application in the dev namespace and to the local server. <br>
  All other namespaces are not allowed. <br>
        namespace: 'dev'
        server: 'https://kubernetes.default.svc'
  To deploy the application on all namespaces but not on dev namespace, and to any server. <br>
  You are not allow to deploy it on the dev namespace. <br>
        namespace: '!dev'
        server: 'https://kubernetes.default.svc'

- **Restrict what kinds of objects may or may not be deployed**    (e.g. RBAC, CRDs, DaemonSets, NetworkPolicy etc...) <br>
  To do that we are using **clusterResourceWhitelist**, **namespaceResourceWhitelist**, **clusterResourceBlacklist** and **namespaceResourceBlacklist** blocks. <br>
  Both blocks have 2 different fields **group** and **kind**. <br>

    clusterResourceWhitelist:
      - group: ""
        kind: "Namespace"

    namespaceResourceWhitelist:
      - group: "apps"
        kind: "Deployment"

  The **clusterResourceWhitelist/Blacklist** block accepts cluster scope resources like **namespaces**. <br>
  The **namespaceResourceWhitelist/Blacklist** block accepts namespaced scope resources like **Deployments**. <br>
  Since both blocks are about whitelist, this means that in the above example, my application can use **Namespace** resource but we are not allowed to use all other resources as a
  cluster scope resource, and it can use only **Deployment** but we are not allowed to use all other resources as a namespace scope resource. <br>

    namespaceResourceBlacklist:
      - group: "apps"
        kind: "Deployment"
  In the above example we are specifying that I can't use **Deployment** resources, but I can use all other namespaced resources. <br>

To list all projects: <br>

    kubectl get appproject
    NAME      AGE
    default   6d
**default** this is the default project of ArgoCD, if you do not create a project, our application can use this project as their project. <br>

    kubectl get appproject default -o yaml
    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      creationTimestamp: "2025-02-04T12:24:57Z"
      generation: 1
      name: default
      namespace: argocd
      resourceVersion: "10078"
      uid: cdf40985-cc1f-43a4-8ba6-daf7f70fdc79
    spec:
      clusterResourceWhitelist:
      - group: '*'
        kind: '*'
      destinations:
      - namespace: '*'
        server: '*'
      sourceRepos:
      - '*'
    status: {}
In the default project there are no restrictions, we cab use all repositories, all destionations and all resources for our application. <br>
<br>
<br>
Create a new project using **sourceRepos** block to allow only 1 repo: <br>
**project-1.yaml** <br>

    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: project-1
      namespace: argocd
    spec:
      clusterResourceWhitelist:
        - group: "\*"
          kind: "\*"
      destinations:
        - namespace: "\*"
          server: "\*"
      sourceRepos:
        - "https://github.com/rdumitru1/argocd-tutorial"
  Here we are limiting the project to allow only **https://github.com/rdumitru1/argocd-tutorial** repo.
Create a new app:
**app-1.yaml** <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-1
    spec:
      destination: # Where the application is deployed
        namespace: default
        server: https://kubernetes.default.svc
      project: project-1      // Uses the above created project-1 project
      source:
        path: argo-cd/applications/helm/nginx
        repoURL: https://github.com/mohammadll/argo-tutorial.git      // This will fail because is using other repo than is allowed in the project-1 project
        targetRevision: main
Now if you check the ArgoCD web interface you should see this error **application repo https://github.com/mohammadll/argo-tutorial.git is not permitted in project 'project-1'** <br>
Change the repoURL to the allowed git repository and redeployit. <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-1
    spec:
      destination: # Where the application is deployed
        namespace: default
        server: https://kubernetes.default.svc
      project: project-1
      source:
        path: 03-argocd-applications/helm/nginx
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main

Create a new project using **sourceRepos** block to allow all repositories except the one with **\!** in front: <br>
**project-2.yaml** <br>

    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: project-2
      namespace: argocd
    spec:
      clusterResourceWhitelist:
        - group: "*"
          kind: "\*"
      destinations:
        - namespace: "\*"
          server: "\*"
      sourceRepos:
        - "!https://github.com/rdumitru1/argocd-tutorial"       // Except this repository
        - "\*"                                                   // Allow all repositories

Restrict our application using **Destinations**. <br>
**project-3.yaml** <br>

    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: project-3
      namespace: argocd
    spec:
      clusterResourceWhitelist:
        - group: "*"
          kind: "*"
      destinations:
        - namespace: "dev"      // Restrict the application to be deployed only to dev namespace.
          server: "*"
      sourceRepos:
        - "*"
Using the **project-3** with the bellow app will not work because the **destination/namespace** is set to default and the project restricts to dev namespace. <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-3
    spec:
      destination: # Where the application is deployed
        namespace: default
        server: https://kubernetes.default.svc
      project: project-3
      source:
        path: 03-argocd-applications/helm/nginx
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
      targetRevision: main

    k create -f app-3.yaml
    application.argoproj.io/app-3 created

    argocd app list
    NAME          CLUSTER                         NAMESPACE  PROJECT    STATUS   HEALTH   SYNCPOLICY  CONDITIONS        REPO                                              PATH                               TARGET
    argocd/app-3  https://kubernetes.default.svc  default    project-3  Unknown  Unknown  Manual      InvalidSpecError  https://github.com/rdumitru1/argocd-tutorial.git  03-argocd-applications/helm/nginx  main

The error message from the UI is **application destination server 'https://kubernetes.default.svc' and namespace 'default' do not match any of the allowed destinations in project 'project-3'**
