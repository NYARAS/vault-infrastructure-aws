terraform {
  required_version = "1.3.7"

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

  backend "s3" {} // partial backend configuration

}


resource "vault_policy" "reader_policy" {
  name = "reader"
  policy = data.vault_policy_document.reader_policy.hcl
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "app" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "app"
  bound_service_account_names      = ["app"]
  bound_service_account_namespaces = ["app"]
  token_ttl                        = 86400
  token_policies                   = ["reader"]
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${data.terraform_remote_state.eks.outputs.cluster_name}"]
    command     = "aws"
  }
}
