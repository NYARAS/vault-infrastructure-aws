terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0" # Optional but recommended in production
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.7.2"
    }
  }

  backend "s3" {
    bucket               = var.backend_config.s3.bucket
    key                  = var.backend_config.s3.key
    region               = var.backend_config.s3.region
    workspace_key_prefix = var.backend_config.s3.workspace_key_prefix
    dynamodb_table       = var.backend_config.s3.dynamodb_table
  } // partial backend configuration
}
