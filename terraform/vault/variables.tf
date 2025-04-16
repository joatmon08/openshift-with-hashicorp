variable "hcp_terraform_token" {
  type        = string
  sensitive   = true
  description = "HCP Terraform management token"
}

variable "hcp_terraform_organization" {
  type        = string
  description = "HCP Terraform organization"
  default     = "hashicorp-team-da-beta"
}

variable "hcp_terraform_team" {
  type        = string
  description = "HCP Terraform team"
}

variable "kubernetes_ca_crt" {
  type        = string
  sensitive   = true
  description = "OpenShift cluster certificate"
}