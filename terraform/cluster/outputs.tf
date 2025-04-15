output "vault_address" {
  value = hcp_vault_cluster.dev.vault_public_endpoint_url
}

output "vault_token" {
  value     = hcp_vault_cluster_admin_token.dev.token
  sensitive = true
}

output "vault_namespace" {
  value = hcp_vault_cluster.dev.namespace
}