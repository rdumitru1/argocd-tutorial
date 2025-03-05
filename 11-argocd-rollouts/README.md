Argo rollout's is a kubernetes controller and a set of crds which provide advanced deployment capability such as **blue green deployment** and **canary deployment**, and also progressive delivery features to kubernetes.
<br>

There are some difference between 2 different objects. **The native kubernetes deployment object** vs **argo-rollout's**
<br>

**The native kubernetes deployment object** supports the rolling update strategy which provides a basic set of safety guarantees such as readiness probes during an update, however the rolling update strategy faces many limitations.
<br>

Limitations of **deployment object**.
- few controls over the speed of the rollout
- inability to control the traffic flow to the new version
- no ability to query external metrics to verify an update
- unable to automatically abort and rollback the update

<br>

Features of **argo-rollout's**
- blue green update strategy
- canary update strategy
- ingress controller integration
- service mesh integration
- automated rollbacks and automated promotions

<br>

Use cases of **argo-rollout's**
<br>
Let's imagine that a user wants to run a last minute functional test on the new version, before it starts to serve production traffic.
- blue-green deployment strategy
  Argo rollout's allows users to specify a active service and preview service.
  The rollout will configure the preview service to send traffic to the new version while the active service continues to receive production traffic.
  Once a user is satisfied they can promote the preview service to be the new active service.
- canary deployment strategy
  A user wants to slowly give the new version more production traffic, it starts by giving a small percentage of the live traffic and wait a while before giving the new version more traffic, eventually the new version will receive all the production traffic.
  The user specifies the percentage they want the new version to receive and the amount time to wait between percentages.

<br>

**Deployment strategies**
- **The native kubernetes deployment object**
    - Rolling-update slowly
        Replace the old version with the new version.
        As the new version comes up the old version scales down in order to maintain the overall count of the application.
        This is the default strategy of the deployment.
    - Recreate
        Deletes the old version of the application before bring up the new version.
        This ensures that 2 versions of the application never run in the same time but there is downtime during the deployment.

- **Argo-rollouts**
    - Rolling-update
        This is the mutual deployment strategy between this 2 different objects.
    - Blue-green
        Both the new version and old version of the application deployed at the same time.
        During this time only the old version of the application will receive the production traffic, this allows the developers to run tests against new version before switching the live traffic to the new version.
        Then switch traffic to the new version of our application and then delete the previous version.
        ![alt text](image.png)
    - Canary deployment
        Exposes a subset of users to the new version of the application while serving the rest of the traffic to the old version of the application.
        Once the new version is verified to be correct the new version can replace the old version.
        ![alt text](image-1.png)