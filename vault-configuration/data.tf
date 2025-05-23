data "vault_policy_document" "reader_policy" {
  rule {
    path         = "secrets/myproject/*"
    capabilities = ["read"]
    description  = "allow reading secrets from myproject applications"
  }
}

// get the remote state data for eks
data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket         = var.remote_state.eks.bucket
    key            = var.remote_state.eks.key
    region         = var.remote_state.eks.region
    dynamodb_table = var.remote_state.eks.dynamodb_table
  }
}
