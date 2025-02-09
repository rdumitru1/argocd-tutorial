terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "6.2.0"
    }
  }
}

provider "argocd" {
  server_addr = var.server_addr
  username    = var.username
  password    = var.password
  insecure    = var.insecure
}
