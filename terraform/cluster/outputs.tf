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

output "oc_username" {
  value = random_pet.cluster_admin.id
}

output "oc_password" {
  value     = random_password.cluster_admin.result
  sensitive = true
}

output "oc_address" {
  value = module.rosa-hcp.cluster_api_url
}