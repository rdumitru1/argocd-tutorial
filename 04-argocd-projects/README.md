**projects** provide a logical grouping of applications, which is useful when Argo CD is used by multiple teams. <br>
Each applications must belong to a project and by default each application uses a project called default. <br>
**projects** provide the following features: <br>
**Restrict what may be deployed** (trusted Git source repositories). You can specify to an application what repo to use and it use the **sourceRepo** block. <br>
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

**Restrict where apps may be deployed to** (destination clusters and namespaces). You can specify the namespace and server where the application will be deployed. <br>
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

**Restrict what kinds of objects may or may not be deployed**    (e.g. RBAC, CRDs, DaemonSets, NetworkPolicy etc...) <br>
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
Using the **project-3** with the bellow app **app-3.yaml** will not work because the **destination/namespace** is set to default and the project restricts to dev namespace. <br>

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

    kubectl create -f app-3.yaml
    application.argoproj.io/app-3 created

    argocd app list
    NAME          CLUSTER                         NAMESPACE  PROJECT    STATUS   HEALTH   SYNCPOLICY  CONDITIONS        REPO                                              PATH                               TARGET
    argocd/app-3  https://kubernetes.default.svc  default    project-3  Unknown  Unknown  Manual      InvalidSpecError  https://github.com/rdumitru1/argocd-tutorial.git  03-argocd-applications/helm/nginx  main

The error message from the UI is **application destination server 'https://kubernetes.default.svc' and namespace 'default' do not match any of the allowed destinations in project 'project-3'**
<br>
Modify the application **app-3.yaml** to use the dev namespace.

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-3
    spec:
      destination: # Where the application is deployed
        namespace: dev
        server: https://kubernetes.default.svc
      project: project-3
      source:
        path: 03-argocd-applications/helm/nginx
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main

    kubectl create ns dev
    kubectl apply -f app-3.yaml
    application.argoproj.io/app-3 configured
    argocd app list
    NAME          CLUSTER                         NAMESPACE  PROJECT    STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO                                              PATH                               TARGET
    argocd/app-3  https://kubernetes.default.svc  dev        project-3  OutOfSync  Missing  Manual      <none>      https://github.com/rdumitru1/argocd-tutorial.git  03-argocd-applications/helm/nginx  main

To restrict the application not to run on a specific namespace use the **\!** in front of the namespace name. For this have a look at **project-4.yaml** and **app-4.yaml**.
<br>
Restrict our application using resources. <br>
Look at **project-5.yaml**, **project-6.yaml**, **app-5.yaml** and **app-6.yaml**
<br>
<br>
**Project Roles** <br>
Projects include a feature called roles that enable automated access to a project's applications. <br>
This can be used to give a CI pipeline a restricted set of permissions. <br>
For example a CI system may only be able to sync a single app, to read a single app but not change it's source or destination. <br>
Projects can have multiple roles and those roles can have different access granted to them, this permissions are called policies,
and they are stored within the role as a list of policy strings. <br>
A role policy can only grant access to that role and are limited to our application within the roles project. <br>
However the policies have an option for granted wildcard access to any application within a project. <br>
So if we want to grant a system to access to the applications of a project we can use project roles. <br>
By using roles we can generate a token to access an external system to sync/get/create/delete an application. <br>
This permissions can be set and tokens generated by using project roles. <br>
**project-7.yaml**

    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: project-7
      namespace: argocd
    spec:
      clusterResourceWhitelist:
        - group: "*"
          kind: "*"
      namespaceResourceWhitelist:
        - group: "*"
          kind: "*"
      destinations:
        - namespace: "*"
          server: "*"
      sourceRepos:
        - "*"
      roles:
        - name: read-only
          description: "This role can be used only for reading applications."
          policies:
            - p, proj:project-7:read-only, applications, get, project-7/*, allow
**p, proj:project-7:read-only, applications, get, project-7/\*, allow** <br>
- **p,** refers to the project
- **proj:project-7:read-only** **proj:** is the sintax, **project-7** is the name of the project, **read-only** name of the role
- **get** allows only get permissions
- **project-7/\*** refers to all applications from the project, to reference a specific application change the star with the application name.
- **allow** to allow the get

Apply the project. <br>

    k apply -f project-7.yaml
    appproject.argoproj.io/project-7 created
Generat the token. <br>

    argocd proj role create-token project-7 read-only                                                                                                                                                                                        12s
Create token succeeded for proj:project-7:read-only.
    ID: 73df70cc-af65-4571-99ec-44cf452f846c
    Issued At: 2025-02-11T14:27:35+02:00
    Expires At: Never
    Token: <generated_token>

To list the applications for project-7 using the generated token <br>

    kubectl apply -f app-7.yaml
    application.argoproj.io/app-7 created

    argocd app list --auth-token <generated_token>
    NAME          CLUSTER                         NAMESPACE  PROJECT    STATUS     HEALTH   SYNCPOLICY  CONDITIONS  REPO                                              PATH                               TARGET
    argocd/app-7  https://kubernetes.default.svc  dev        project-7  OutOfSync  Missing  Manual      <none>      https://github.com/rdumitru1/argocd-tutorial.git  03-argocd-applications/helm/nginx  main

Create 2 new apps **app-8.yaml** and **app-9.yaml** using the same **project-7.yaml** project, sync **app-8.yaml** using the admin permissions and try to sync **app-9.yaml** using the generated token. <br>

    kubectl create -f app-8.yaml
    application.argoproj.io/app-8 created

    kubectl create -f app-9.yaml
    application.argoproj.io/app-9 created

    argocd app sync app-8   // sync will work

    argocd app sync app-9 --auth-token <generated token>
    FATA[0000] rpc error: code = PermissionDenied desc = permission denied: applications, sync, project-7/app-9, sub: proj:project-7:read-only, iat: 2025-02-11T12:27:35Z

Modify **project-7.yaml** and add a new policy that allows sync as well. <br>

    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
    name: project-7
    namespace: argocd
    spec:
      clusterResourceWhitelist:
        - group: "*"
          kind: "*"
      namespaceResourceWhitelist:
        - group: "*"
          kind: "*"
      destinations:
        - namespace: "*"
          server: "*"
      sourceRepos:
        - "*"
      roles:
        - name: read-sync
          description: "This role can be used only for reading applications."
          policies:
            - p, proj:project-7:read-sync, applications, get, project-7/*, allow
            - p, proj:project-7:read-sync, applications, sync, project-7/*, allow
Apply the change, generate a new token based on the new role and the new policy and test again the sync using the generated token. <br>

    argocd proj role create-token project-7 read-sync
    Create token succeeded for proj:project-7:read-sync.
      ID: a7f8865b-f859-4888-9430-f4e068acb99c
      Issued At: 2025-02-11T15:46:26+02:00
      Expires At: Never
      Token: <generated_token>
    argocd app sync app-9 --auth-token <generated_token>   // sync will now work
