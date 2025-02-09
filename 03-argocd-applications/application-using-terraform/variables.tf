variable "username" {
  type        = string
  description = "ArgoCD username"
}

variable "password" {
  type        = string
  description = "ArgoCD password"
}

variable "server_addr" {
  type        = string
  description = "ArgoCD server name"
}

variable "namespace" {
  type        = string
  description = "Namespace Value"
}

variable "destination_namespace" {
  type        = string
  description = "Destination Namespace Value"
}

variable "destination_server" {
  type        = string
  description = "Destination Server Value"
}

variable "repo_url" {
  type        = string
  description = "Repo_url Value"
}

variable "path" {
  type        = string
  description = "Path Value"
}

variable "target_revision" {
  type        = string
  description = "Target_revision Value"
}

variable "values_files" {
  type        = list(string)
  description = "Values_files Value as a list"
}

variable "insecure" {
  type        = bool
  description = "Since we are using self signed certificates this needs to be set to true."
}
