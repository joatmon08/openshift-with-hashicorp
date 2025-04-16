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

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = data.terraform_remote_state.cluster.outputs.oc_address
  kubernetes_ca_cert = base64decode(var.kubernetes_ca_crt)
}

data "vault_policy_document" "terraform_operator" {
  rule {
    path         = "${vault_terraform_cloud_secret_backend.dev.backend}/creds/${vault_terraform_cloud_secret_role.dev.name}"
    capabilities = ["read"]
    description  = "Get HCP Terraform team API token"
  }
}

resource "vault_policy" "terraform_operator" {
  name   = "terraform-operator"
  policy = data.vault_policy_document.terraform_operator.hcl
}

resource "vault_kubernetes_auth_backend_role" "terraform_operator" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "terraform"
  bound_service_account_names      = ["terraform-operator"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 43200
  token_policies                   = [vault_policy.terraform_operator.name]
  audience                         = "vault"
}