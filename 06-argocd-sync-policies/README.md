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