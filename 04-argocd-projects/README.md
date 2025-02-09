**projects** provide a logical grouping of applications, which is useful when Argo CD is used by multiple teams.
**projects** provide the following features
- **Restrict what may be deployed** (trusted Git source repositories). You can specify to an application what repo to use and it use the **sourceRepo** block.
  Lets presume that we have **application1**, and I want that my **application1** uses this repository **https://github.com/rdumitru1/argocd-tutorial.git**.
      sourceRepos:
        https://github.com/rdumitru1/argocd-tutorial.git
  If this application uses another repository, it can't be deployed, so it is allowed to use this repository only.
  This is like a wite list and I can add other repositories as well.
  If I use other repositories than the one specified, it can't be deployed.
  I can use **!** in front of a repository it means that I can't use this repository. If my application is using this repositories, it can't be deployed.
      sourceRepos:
        !https://github.com/rdumitru1/argocd-tutorial.git
  If I want my application not to use a specific repository and use all other repositories.
      sourceRepos:
        !https://github.com/rdumitru1/argocd-tutorial.git
        "*"
