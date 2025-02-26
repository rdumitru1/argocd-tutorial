username              = "argo_username"
password              = "argo_password"
namespace             = "argocd"
destination_namespace = "sync-policy-options"
destination_server    = "https://kubernetes.default.svc"
server_addr           = "darkscience.local"
insecure              = true
repo_url              = "https://github.com/rdumitru1/argocd-tutorial.git"
path                  = "03-argocd-applications/directoryofmanifests"
target_revision       = "main"
prune_enabled         = true
selfheal_enabled      = true
sync_options          = ["CreateNamespace=true", "FailOnSharedResource=true"]
namespace_metadata_labels = {
  created_by     = "Terraform"
  Course_creator = "dmr"
}