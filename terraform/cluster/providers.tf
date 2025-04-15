terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.1"
    }

    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1.6.8"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.104.0"
    }
  }
}

provider "rhcs" {}

provider "aws" {
  region = var.region

  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }

  default_tags {
    tags = var.default_aws_tags
  }
}

provider "hcp" {}