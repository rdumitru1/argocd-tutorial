## This only works with this repo https://github.com/rdumitru1/argocd-tutorial-private

The first method to authenticate Argo with a private git repo is using https and a git token. <br>
**https-secret.yaml** <br>

    apiVersion: v1
    kind: Secret
    metadata:
      name: argocd-private-repo
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repository                    # This is import to define
    stringData:
      type: git
      url: https://github.com/rdumitru1/argocd-tutorial-private.git   # https url
      username: argocd-private-repo                                   # name of the token
      password: the_generated_token                                   # the generated token itself

In Argo go to settings/repositories to see the above configured repo

The second method to authenticate Argo with a private git repo is using ssh. <br>

    apiVersion: v1
    kind: Secret
    metadata:
      name: argocd-private-repo-ssh
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repository    # This is import to define
    stringData:
      type: git
      url: git@github.com:rdumitru1/argocd-tutorial-private.git
      sshPrivateKey: |
        -----BEGIN OPENSSH PRIVATE KEY-----
        Private Key
        -----END OPENSSH PRIVATE KEY-----

In Argo go to settings/repositories to see the above configured repositories. <br>

The private repositories can be created via: <br>
**UI** <br>
Go to **Settings/Repositories** and click on **Connect Repo** <br>

**CLI** <br>
# Add a private Git repository via HTTPS using username/password without verifying the server's TLS certificate <br>

    argocd repo add https://git.example.com/repos/repo --username git --password secret --insecure-skip-server-verification <br> <br>

 # Add a private Git repository via HTTPS using username/password and TLS client certificates: <br>

    argocd repo add https://git.example.com/repos/repo --username git --password secret --tls-client-cert-path ~/mycert.crt --tls-client-cert-key-path ~/mycert.key

# Add a Git repository via SSH using a private key for authentication, ignoring the server's host key: <br>

    argocd repo add git@git.example.com:repos/repo --insecure-ignore-host-key --ssh-private-key-path ~/id_rsa


<br>
Look at **argocd repo add -h** command for more options on how to add private repositories. <br>

Create an app using the https repository url. <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-private
      namespace: argocd
    spec:
      destination:
        namespace: default
        server: "https://kubernetes.default.svc"
      project: default
      source:
        path: 05-argocd-private-repos/applications/helm/nginx
        repoURL: "https://github.com/rdumitru1/argocd-tutorial-private.git"
        targetRevision: main

    k create -f app.yaml

Check the ArgoCD applications and hit an sync. <br>

Create an app using the ssh repository url. <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-ssh-private
      namespace: argocd
    spec:
      destination:
        namespace: default
        server: "https://kubernetes.default.svc"
      project: default
      source:
        path: 05-argocd-private-repos/applications/helm/nginx
        repoURL: "git@github.com:rdumitru1/argocd-tutorial-private.git"
        targetRevision: main

    k create -f app-ssh.yaml

Check the ArgoCD applications and hit an sync. <br>

At this moment in the **settings/repositories** we have defined 2 private repositories. <br>
Instead of defining multiple repositories we can define a credential template for multiple private repositories. <br>
First delete all private repositories from **settings/repositories**. <br>
**template.yaml**

    apiVersion: v1
    kind: Secret
    metadata:
      name: argocd-template
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repo-creds    # This is import to define
    stringData:
      type: git
      url: https://github.com/rdumitru1
      username: argocd-private-repo     # name of the token
      password: the_generate_token    # the generated token itself

The label has changed from **repository** to **repo-creds** <br>
The **url** was trimmed as well to just **https://github.com/rdumitru1**. Being a template it will apply to all repositories that matches this prefix **https://github.com/rdumitru1**.
<br>
Check the **settings/repositories** to view the new configured template.
<br>
Apply the **app-template.yaml** <br>

    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-private-template
      namespace: argocd
    spec:
      destination:
        namespace: default
        server: "https://kubernetes.default.svc"
      project: default
      source:
        path: 05-argocd-private-repos/applications/helm/nginx
        repoURL: "https://github.com/rdumitru1/argocd-tutorial-private.git"
        targetRevision: main

In the applications tab, sync the new created application.
<br>
<br>
To use terraform to create a private repository go to **private-repos-using-terraform** run **terraform init**, **terraform validate**, **terraform plan**, and **terraform apply --auto-approve**.
<br>
Check the **setting/repositories** to view the new created private repository.