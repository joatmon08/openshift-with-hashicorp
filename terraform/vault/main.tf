resource "vault_terraform_cloud_secret_backend" "dev" {
  backend     = "terraform"
  description = "Manages the Terraform Cloud backend"
  token       = var.hcp_terraform_token
}

resource "vault_terraform_cloud_secret_role" "dev" {
  backend      = vault_terraform_cloud_secret_backend.dev.backend
  name         = "operator"
  organization = var.hcp_terraform_organization
  team_id      = var.hcp_terraform_team
}