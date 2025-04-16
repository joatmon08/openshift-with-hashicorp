terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.7.0"
    }
  }
}

data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = "hashicorp-team-da-beta"
    workspaces = {
      name = "openshift-with-hashicorp-cluster"
    }
  }
}

provider "vault" {
  address   = data.terraform_remote_state.cluster.outputs.vault_address
  namespace = data.terraform_remote_state.cluster.outputs.vault_namespace
  token     = data.terraform_remote_state.cluster.outputs.vault_token
}