data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  # Extract availability zone names for the specified region, limit it to 3 if multi az or 1 if single
  region_azs = var.multi_az ? slice([for zone in data.aws_availability_zones.available.names : format("%s", zone)], 0, 3) : slice([for zone in data.aws_availability_zones.available.names : format("%s", zone)], 0, 1)
}

resource "random_string" "random_name" {
  length  = 6
  special = false
  upper   = false
}

locals {
  worker_node_replicas = var.multi_az ? 3 : 2
  # If cluster_name is not null, use that, otherwise generate a random cluster name
  cluster_name = coalesce(var.cluster_name, "rosa-${random_string.random_name.result}")
}

# The network validator requires an additional 60 seconds to validate Terraform clusters.
resource "time_sleep" "wait_60_seconds" {
  count           = var.create_vpc ? 1 : 0
  depends_on      = [module.vpc]
  create_duration = "60s"
}

resource "random_pet" "cluster_admin" {
  length = 1
}

resource "random_password" "cluster_admin" {
  length  = 16
  special = false
}

module "rosa-hcp" {
  source                 = "terraform-redhat/rosa-hcp/rhcs"
  version                = "1.6.5"
  cluster_name           = local.cluster_name
  openshift_version      = var.openshift_version
  replicas               = local.worker_node_replicas
  aws_availability_zones = local.region_azs
  create_oidc            = true
  private                = var.private_cluster

  aws_subnet_ids = var.create_vpc ? var.private_cluster ? module.vpc[0].private_subnets : concat(module.vpc[0].public_subnets, module.vpc[0].private_subnets) : var.aws_subnet_ids

  create_account_roles  = true
  account_role_prefix   = local.cluster_name
  create_operator_roles = true
  operator_role_prefix  = local.cluster_name

  admin_credentials_username = random_pet.cluster_admin.id
  admin_credentials_password = random_password.cluster_admin.result

  depends_on = [time_sleep.wait_60_seconds]
}
