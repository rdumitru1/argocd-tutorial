## Sync Policies
<br> <br>

**Automated Sync**
<br>
Until now when we deployed an application we needed to sync it manually to create the resources.
<br>
Also when an application is already deployed and you modify the manifest of a deployment and push the changes, Argo will change it state to OutOfSync.
<br>
**Automated Sync** has the ability to automatically Sync an application when it detects differences between the desired manifest in git and the live state in the cluster.
<br>
One benefit is that the CI/CD pipelines no longer need direct access to the ArgoCD API Server to perform the deployment instead the pipeline make a commit and push to the git repository with the changes to the manifest in the tracking git repository.
<br>
**app-no-automated-sync.yaml**
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: application-no-automated-sync
    spec:
      destination: # Where the application is deployed
        namespace: no-automated-sync
        server: https://kubernetes.default.svc
      project: default
      source:
        directory:
          recurse: true
        path: 03-argocd-applications/directoryofmanifests
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main

    kubectl create ns no-automated-sync
    kubectl create -f app-no-automated-sync.yaml

This application should be synced manually.
<br>
Change the replicas from 1 to 3 in **03-argocd-applications/directoryofmanifests/deployment.yaml** and refresh the application in UI and you will see that is OutOfSync and needs to be manually synced.

**automated-sync.yaml**
<br>
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: automated-application
    spec:
      destination:
        namespace: automated-sync
        server: https://kubernetes.default.svc
      project: default
      source:
        path: v03-argocd-applications/directoryofmanifests
        repoURL: https://github.com/rdumitru1/argocd-tutorial.git
        targetRevision: main
      syncPolicy:           # This is a new directive
        automated: {}       # This means that this application is automated sync

    kubectl create ns automated-sync
    kubectl create -f automated-sync.yaml

If you go to the UI and verify, you will see that the application is automatically synced.
<br>
Change the replica back from 3 to 1 and go to UI refresh the app and see that the application is automatically synced.
<br>
If we delete a kubernetes manifest from git **03-argocd-applications/directoryofmanifests/service.yaml** and in the UI you refresh you will see that the application will be OutOfSync and a trash icon will appear on the service, if you synchronies the application you will see that the service will still be present.
<br>
In order to correctly synchronies the application when you click on sync check the **PRUNE** box as well and the Synchronize, and you will see that the service disappears.
<br>
The above **PRUNE** operation was done manually, now let's do this automatically.
<br>
First get back the deleted **03-argocd-applications/directoryofmanifests/service.yaml** file and in the UI hit a refresh to see that ArgoCD creates automatically the reverted **service.yaml** file.
<br>
**prune-sync.yml**

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: prune-application
    spec:
      destination:
        namespace: prune-sync
        server: https://kubernetes.default.svc
      project: default
      source:
        path: v03-argocd-applications/directoryOfmanifests
        repoURL: https://github.com/devopshobbies/argocd-tutorial.git
        targetRevision: main
      syncPolicy:
        automated:
          prune: true     # This will automatically PRUNE the resources that gets deleted.
        
    kubectl create ns prune-sync
    kubectl create -f prune-sync.yml

If now we delete again the **03-argocd-applications/directoryofmanifests/service.yaml** file, in the UI we will see that the service resource will be automatically removed.
<br>
Get back the deleted **03-argocd-applications/directoryofmanifests/service.yaml** file and in the UI hit a refresh to see that ArgoCD creates automatically the reverted **service.yaml** file.
<br>