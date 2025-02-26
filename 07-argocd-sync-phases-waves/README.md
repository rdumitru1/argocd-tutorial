ArgoCD executes and deploys all the resources in the Kubernetes cluster based on priorities.
<br>
There are multiple priorities in ArgoCD to deploy the resources and ArgoCD examine all of them in order.
<br>
The first and most important priority to deploy the resources in ArgoCD is **Sync Phases**, the second one are **Sync Waves**, third one is **by Kind** and forth is **By Name**.

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

<br>
This **07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/deployment.yaml** file does not have any annotation and it means that it will run in Sync phase.
<br>
This **07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/pre-job.yaml** has the **argocd.argoproj.io/hook: PreSync** annotation and it will run in Pre-sync phase. Here I want to use this pre-job to monitor the health status of our application, if the application is healthy we can deploy the new version of our application and after that I want to send a notification on a chat ops service (mattermost) to inform all other users about the last Sync result.
<br>
If Sync operation fails I want to use a fail job to send a notification to mattermost to inform all the users that Sync operation failed. **07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/fail-job.yaml** file has **argocd.argoproj.io/hook: SyncFail** annotation.
<br>
**07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/pre-job.yaml**, this file checks if the mattermost app is running, the Pre-sync job succeed, returns 0 and Sync phase will run, or if it's not running the Pre-job fails, returns 1 and the Sync job will not run.
<br>
**07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/post-job.yaml**, I want to use this job to send notifications to our mattermost service to inform the user about the last Sync result. The post job will run if Sync phase complete and all the resources of that Phase becomes healthy.
<br>
**Not able to follow along because of the mattermost server installation.**
<br>
## Hook Deletion Policies
<br>
There are 3 different types hook deletion policies in ArgoCD.
<br>
When running jobs in the different Sync phases it will create kubernetes job resources, and we can use Hook Deletion policies to delete this hook resources.
<br>
1. HookSucceeded
<br>
This means that the hook resource is deleted after the hook succeed. For example my pre-job was succeed so it will deleted from our kubernetes cluster if it uses this **HookSucceeded** annotation.
<br>
2. HookFailed
<br>
This means that the hook resource is deleted after the hook failed.
<br>
3. BeforeHookCreation
<br>
This is the default hook deletion policy
<br>
This means that any existing hook resource is deleted before new one is created, it will available until the new resource will be created.
<br>
**07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/pre-job.yaml** has the **argocd.argoproj.io/hook-delete-policy: HookFailed** annotation which means that the this job will get deleted when the Sync status failed.
<br>
If the annotation would be **argocd.argoproj.io/hook-delete-policy: HookSucceeded** would mean that the job would get deleted when the Sync status is ok.

## Sync Waves
<br>
Wave is a number, it can be a negative number (-1, -2), it can be 0 and it can be a positive number (+1, +2).
<br>
The default wave for all resources is 0.
<br>
In the bellow table if I want ArgoCD to deploy the Service first and the the Service account we will need to change the wave number for each resource.
<br>
The lowest number has the highest priority, -10 has a higher priority than -2 or 0 or +1.
<br>

| Pre-sync   | Sync/wave          | Post-sync  | Sync-fail|
| :----------| :------------------| :----------| :------- |
| Job        | Service -2         | Job        | Job      |
|            | Deployment 0       |            |          |
|            | ServiceAccount -1  |            |          |

<br>
So in this table the Service will get deployed first, ServiceAccount second and Deployment third.
<br>
This applies only to the Sync phase because there the Sync Waves was set.
<br>
Sync Waves is the order of deploying the resources into a specific phase.
<br>
**07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/service.yaml** has the **argocd.argoproj.io/sync-wave: "-2"** annotation which tells ArgoCD to deploy the Service first in the Sync Phase
<br>
**07-argocd-sync-phases-waves/sync-phases-waves-manifests-examples/serviceaccount.yaml** has the **argocd.argoproj.io/sync-wave: "-1"** annotation which tells ArgoCD to deploy Service Account second after the Service.
<br>

## By Kind
<br>
| Pre-sync   | Sync/wave         | Post-sync  | Sync-fail|
| :----------| :-----------------| :----------| :------- |
| Job        | Service 0         | Job        | Job      |
|            | Deployment 0      |            |          |
|            | ServiceAccount 0  |            |          |

<br>
When in Sync Phase we have the same Sync Wave number, in the above table 0, then ArgoCD looks at the kind of the resources.
<br>
ArgoCD will deploy the resources based on their kind.
<br>
In this url https://github.com/argoproj/gitops-engine/blob/master/pkg/sync/sync_tasks.go in the **init** function there is a **kinds** variable where is a list with the kubernetes object kinds.
<br>
The priority in which ArgoCD deploys the objects is based on this list, the priority is from top to bottom, highest priority on top.
<br>
This priority is used when when phases and waves are equal for multiple resources.
<br>

## By Name
<br>
Let's say that we have 2 different Service Accounts, the Phase is equal, the Wave is equal, the kind is equal, in this situation ArgoCD will deploy this 2 resources based on their names, in order.
<br>
| Pre-sync   | Sync/wave         | Post-sync  | Sync-fail|
| :----------| :-----------------| :----------| :------- |
| Job        | Service 0         | Job        | Job      |
|            | Deployment 0      |            |          |
|            | ServiceAccount 0  |            |          |
|            | ServiceAccount 0  |            |          |
