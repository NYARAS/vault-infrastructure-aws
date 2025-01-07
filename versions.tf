terraform {
  required_version = ">= 0.15.0"

  backend "s3" {
    bucket               = var.backend_config.s3.bucket
    key                  = var.backend_config.s3.key
    region               = var.backend_config.s3.region
    workspace_key_prefix = var.backend_config.s3.workspace_key_prefix
    dynamodb_table       = var.backend_config.s3.dynamodb_table
  } // partial backend configuration
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.2"
    }

  }
}
