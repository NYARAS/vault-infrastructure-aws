# # // INIT THE VAULT
resource "vault_jwt_auth_backend" "gitlab" {
  description        = "JWT auth backend for Gitlab-CI pipeline"
  path               = "jwt"
  oidc_discovery_url = "https://gitlab.com"
  bound_issuer       = "https://gitlab.com"
  default_role       = "default"
  tune {
    default_lease_ttl = var.jwt_auth_tune_default_ttl // tokem ttl
    max_lease_ttl     = var.jwt_auth_tune_max_ttl     // token max ttl
    token_type        = "default-service"
  }
}

resource "vault_auth_backend" "aws" {
  description = "Auth backend to auth project in AWS env"
  type        = "aws" // AWS Auth backend
  path        = "${var.project_name}-aws"
}

resource "vault_aws_secret_backend" "aws" {
  description               = "AWS secret engine for Gitlab-CI pipeline"
  path                      = "${var.project_name}-aws"
  region                    = var.region
  default_lease_ttl_seconds = var.aws_secret_default_ttl
  max_lease_ttl_seconds     = var.aws_secret_max_ttl
}

data "vault_policy_document" "pipeline_aws_read" {
  rule {
    required_parameters = []
    path                = "${vault_aws_secret_backend.aws.path}/sts/${vault_aws_secret_backend_role.pipeline.name}"
    capabilities        = ["read"]
    description         = "Allow to read AWS secrets"
  }
  rule {
    required_parameters = []
    path                = "auth/${vault_auth_backend.aws.path}/*"
    capabilities        = ["read", "update", "create", "delete", "list"]
    description         = "Allow to manage authentification into the Vault with AWS auth method"
  }
  rule {
    required_parameters = []
    path                = "auth/token/create"
    capabilities        = ["update"]
    description         = "Allow pipeline to create a Vault child token when using Terraform"
  }
}

resource "vault_policy" "pipeline" {
  name   = "${var.project_name}-pipeline"
  policy = data.vault_policy_document.pipeline_aws_read.hcl
}

resource "vault_jwt_auth_backend_role" "pipeline" {
  backend   = vault_jwt_auth_backend.gitlab.path
  role_type = "jwt"

  role_name       = "${var.project_name}-pipeline"
  token_policies  = ["default", vault_policy.pipeline.name]
  bound_audiences = var.bound_audiences

  bound_claims = {
    project_id = var.gitlab_project_id
    ref        = var.gitlab_project_branch
    ref_type   = "branch"
  }
  user_claim             = "user_email"
  token_explicit_max_ttl = var.jwt_token_max_ttl
}

resource "vault_aws_secret_backend_role" "pipeline" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "${var.project_name}-pipeline"
  credential_type = "assumed_role"
  role_arns       = [var.gitlab_pipeline_aws_assume_role] // The role Vault will assume
}
