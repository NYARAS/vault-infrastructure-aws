provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${data.terraform_remote_state.eks.outputs.cluster_name}"]
    command     = "aws"
  }
}

// Add vault provider config
provider "vault" {
  address = var.vault_endpoint
  token   = var.vault_token
}
