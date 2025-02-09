resource "argocd_application" "helm" {
  metadata {
    name      = "helm-app-using-terraform"
    namespace = var.namespace
    labels = {
      test = "true"
    }
  }

  spec {
    destination {
      server    = var.destination_server
      namespace = var.destination_namespace
    }

    source {
      repo_url = var.repo_url # It works with helm chart as well
      # chart           = "mychart"  # Used only with helm chart
      path            = var.path            # It is used when a git repository is specified
      target_revision = var.target_revision # It can be a commit ID, a branch, or a tag when a git repository it's used
      helm {
        # release_name = "testing"  # Because I want to use the name specified in metadata/name I commented this out
        value_files = var.values_files
      }
    }
  }
}
