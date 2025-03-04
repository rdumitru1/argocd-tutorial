    kubectl get pods -n argocd
    NAME                                               READY   STATUS    RESTARTS       AGE
    argocd-application-controller-0                    1/1     Running   55 (10d ago)   23d
    argocd-applicationset-controller-b8948cbb4-htbxz   1/1     Running   3 (10d ago)    23d         # This is the applicationset controller
    argocd-dex-server-5cfd89f4c4-zhmgr                 1/1     Running   3 (10d ago)    23d
    argocd-notifications-controller-5b7946c7d8-wtk8t   1/1     Running   3 (10d ago)    23d
    argocd-redis-7c59b56464-28scd                      1/1     Running   3 (10d ago)    23d
    argocd-repo-server-77b8c4fb84-55bm6                1/1     Running   51 (10d ago)   23d
    argocd-server-bf56f7d5-k6hqf                       1/1     Running   41 (10d ago)   23d


The applicationset controller enables both automation and greater flexibility managing ArgoCD Applications across a large number of clusters.
<br>
The applicationset controller works alongside an existing ArgoCD installation.
<br>
Starting with ArgoCD version 2.3 the applicationset controller is bundled with ArgoCD.
<br>
Let's say that we have 3 different clusters in ArgoCD environment, cluster A, cluster B and cluster C.
<br>
To deploy an application on this 3 clusters we need to create 3 different manifest ArgoCD application files.
<br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: new-cluster-application
      namespace: argocd
    spec:
      destination: # Where the application is deployed
        namespace: external
        name: in-cluster # In order to deploy on all 3 different clusters we need 3 different files with the **name** changed to point to all 3 clusters
      project: default
      source:
        path: 03-argocd-applications/directoryofmanifests
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
        automated: {}

The above solution is not ideal, if we had 10 clusters we would need 10 different files.
<br>
**applicationset** help us fix the problem of having multiple files, by just writing a single kubernetes manifest to generate multiple applications.
<br>
<br>

## Generators
<br>
I want applicationset to generate applications because of that we have multiple different generators in ArgoCD.
<br>
### List generator
<br>
List generator is responsible for generating parameters. Parameters are key value pairs that are substituted into the **template** section of the applicationset resource during template rendering.
<br>
**list-generator-ex1.yaml**
<br>

    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: list-generator-ex1
      namespace: argocd
    spec:
      generators:
      - list:
          elements:
          - cluster: local                                   # first element in the list generator
            url: https://kubernetes.default.svc
            path: directoryofmanifests
          - cluster: external                                # second element in the list generator
            url: https://kubernetes.default.svc              # https://192.168.64.93:6443 I added https://kubernetes.default.svc because I don't have the second cluster configured.
            path: helm/nginx
      template:                                              # Under this block is the definition of an application 
        metadata:
          name: '{{cluster}}-application'                    # this will be **local-application** because of the first element and **external-application** because of the second element
        spec:
          project: default
          source:
            repoURL: https://github.com/rdumitru1/argocd-tutorial.git
            targetRevision: main
            path: 03-argocd-applications/{{path}}            # The {{path}} will take the value from the path key from the elements in the list generator.
          destination:
            server: '{{url}}'                                # The {{url}} will take the value from the path key from the elements in the list generator.
            namespace: '{{cluster}}'                         # The {{cluster}} will take the value from the path key from the elements in the list generator.
          syncPolicy:
            automated: {}
            syncOptions:
              - CreateNamespace=true

    kubectl apply -f list-generator-ex1.yaml

In the UI both application got deployed.
<br>
![alt text](image.png)

In the above example we are using 3 variables {{cluster}}, {{url}} and {{path}}.
<br>
The goal is generating applications so we are using a generator called **list**.
<br>
In the **list** generator we have 2 different elements, so we have 2 different applications.
<br>
### Cluster generator
<br>
Allows you to target ArgoCD applications to clusters based on the list of clusters defined within and managed by ArgoCD.
<br>
In ArgoCD managed clusters are stored within secrets in the ArgoCD namespace.
<br>
In the previous lecture we used a secret to add a new Kubernetes cluster to ArgoCD environment, applicationset controller uses those same secrets to generate parameters to identify and target available clusters.
<br>
For each cluster registered with ArgoCD the **Cluster Generator** produces parameters based on the list of items found within the cluster secret.
<br>
The cluster generator will provide some different parameters that we can use in applicationset manifest related to **Cluster Generator**.
<br>

**Parameters**
<br>

**name** - Is equal with stringData.secret from the secret
<br>

**namenormalized** - Normalize to contain only lowercase alpha numerical correctors. Also it will convert underline(_) to dash (-), test_a will become test-a
<br>

**server** - Is equal with stringData.server from the secret
<br>

**metadata.labels.<key>** Is equal with metadata.labels.<key>
<br>

**metadata.annotations.<key>** Is equal with metadata.annotations.<key>
<br>
Since I did not deployed the second cluster in a VM I can't follow this.
<br>

**cluster-generator-ex1.yaml**
<br>

    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: cluster-generator-ex1
      namespace: argocd
    spec:
      generators:
      - clusters: {}
      template:
        metadata:
          name: '{{name}}-application'
        spec:
          project: "default"
          source:
            repoURL: https://github.com/devopshobbies/argocd-tutorial.git
            targetRevision: main
            path: v03-argocd-applications/helm/nginx
          destination:
            server: '{{server}}'
            namespace: cluster-generator
          syncPolicy:
            automated: {}
            syncOptions:
              - CreateNamespace=true

In the above file we have 2 variables **{{name}}** and **{{server}}**. This variables come from the output of **argocd cluster list**.
<br>

    argocd cluster list
    SERVER                          NAME        VERSION  STATUS      MESSAGE  PROJECT
    https://kubernetes.default.svc  in-cluster  1.27     Successful

If I would had multiple clusters it would look like this.
<br>

    argocd cluster list
    SERVER                          NAME        VERSION  STATUS      MESSAGE  PROJECT
    https://192.168.64.93:6443      external    1.27     Successful
    https://kubernetes.default.svc  in-cluster  1.27     Successful

The first variable is **{{name}}**, and name of the first cluster is **in-cluster** so the name of the first application will be **in-cluster-application** and the name of the second application will be **external-application**, if we would have 10 clusters we would had 10 different applications.
<br>

The second variable is **{{server}}**, where we are defining the server, we are defining the destination.
<br>
The server of the first application will be **https://kubernetes.default.svc** and the server for the second application will be **https://192.168.64.93:6443**.
<br>

    kubectl apply -f cluster-generator-ex1.yaml

Since I have a single kubernetes cluster I only have one application deployed.
<br>

![alt text](image-1.png)

<br>
Sometimes I want to deploy my application in some specific cluster in one or more specific clusters.
<br>

I want application A to be deployed in a cluster that has a specific label, in this situation we can use selectors in Cluster Generator to select some specific clusters for this purpose.
<br>

**cluster-generator-ex2.yaml**
<br>

    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: cluster-generator-ex2
      namespace: argocd
    spec:
      generators:
      - clusters:
          selector:
            matchLabels:                                    # I want my application to be deployed in a cluster that has this 2 labels. This are the labels from the secret 08-argocd-add-cluster/add-cluster/add-cluster-manifest/add-cluster-secret.yaml metadata.labels
              argocd.argoproj.io/secret-type: cluster
              environment: staging
      template:
        metadata:
          name: '{{name}}-application'
        spec:
          project: "default"
          source:
            repoURL: https://github.com/rdumitru1/argocd-tutorial.git
            targetRevision: main
            path: 03-argocd-applications/helm/nginx
          destination:
            server: '{{server}}'
            namespace: cluster-generator
          syncPolicy:
            automated: {}
            syncOptions:
              - CreateNamespace=true

