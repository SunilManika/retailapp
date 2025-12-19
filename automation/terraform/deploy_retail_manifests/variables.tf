variable "namespace" {
  description = "Target OpenShift namespace"
  type        = string
}

variable "ocp_server" {
  description = "OpenShift API server URL"
  type        = string
}

variable "ocp_token" {
  description = "OpenShift API token"
  type        = string
  sensitive   = true
}

