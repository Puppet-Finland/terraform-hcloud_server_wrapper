terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">= 1.42.1"
    }
  }
}
