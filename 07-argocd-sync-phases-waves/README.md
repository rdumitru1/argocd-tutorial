ArgoCD executes and deployes all the resources in the Kubernetes cluster based on priorities.
<br>
There are multiple priorities in ArgoCD to deploy the resources and ArgoCD examine all of them in order.
<br>
The first and most important priority to deploy the resources in ArgoCD is Sync Phases.

## Sync Phases
<br>
ArgoCd executes a Sync operation in a number of steps.
<br>
There are 4 phases.
<br>
1. Pre-sync
We want to perform a database schema migration or check the health of the application or anything else before deploying a new version of the application.
<br>
So we define a job (health check of the application) and place it in Pre-sync phase to execute before Sync phase.
<br>
We can have one or multiple resources in Pre-sync phase and ArgoCD will run Pre-sync phase first and once the Pre-sync phase completes and all the resources in that phase become healthy the Sync phase will run and the resources will be deployed in the cluster.
2. Sync
By default all the resources are in the Sync phase. We can change the default behavior of a resource and we can place a resource into another phase.
<br>

3. Post-sync
We are going to send a notification to a chat ops service like slack to inform  users that the result of the last Sync was ok.
<br>
We define a job and place it in Post-sync phase. The job will run if Sync phase completes and all the resources in that phase become healthy. If Sync phase fails Post-sync phase won't run.
<br>
4. Sync-fail
It executes when Sync phase fail, for example we send a notification to inform users that the result of the last Sync failed.
<br>
<br>
To define the Phases of a resource we use **ArgoCD hooks** annotation.
<br>

| Pre-sync   | Sync          | Post-sync  | Sync-fail|
| :----------| :-------------| :----------| :------- |
| Job        | Service       | Job        | Job      |
|            | Deployment    |            |          |
|            | ServiceAccount|            |          |