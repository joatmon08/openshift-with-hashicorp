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