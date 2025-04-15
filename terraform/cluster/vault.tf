resource "hcp_hvn" "dev" {
  hvn_id         = var.cluster_name
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = var.hcp_cidr_block
}

resource "hcp_aws_network_peering" "dev" {
  peering_id      = "${var.cluster_name}-peering"
  hvn_id          = hcp_hvn.dev.hvn_id
  peer_vpc_id     = module.vpc.0.vpc_id
  peer_account_id = module.vpc.0.vpc_owner_id
  peer_vpc_region = var.region
}

data "hcp_aws_network_peering" "dev" {
  hvn_id                = hcp_hvn.dev.hvn_id
  peering_id            = hcp_aws_network_peering.dev.peering_id
  wait_for_active_state = true
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.dev.provider_peering_id
  auto_accept               = true
}
resource "hcp_hvn_route" "dev" {
  hvn_link         = hcp_hvn.dev.self_link
  hvn_route_id     = "${var.cluster_name}-route"
  destination_cidr = module.vpc.0.vpc_cidr_block
  target_link      = data.hcp_aws_network_peering.dev.self_link
}

resource "hcp_vault_cluster" "dev" {
  cluster_id      = var.cluster_name
  hvn_id          = hcp_hvn.dev.hvn_id
  tier            = "plus_small"
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "dev" {
  cluster_id = hcp_vault_cluster.dev.cluster_id
}