variable "remote_state" {
  description = "Remote state data for eks"
  type = object({
    eks = object({
      bucket               = string
      key                  = string
      region               = string
      workspace_key_prefix = optional(string)
      dynamodb_table       = string
    })
  })
}

variable "backend_config" {
  description = "Remote state data for eks"
  type = object({
    s3 = object({
      bucket               = string
      key                  = string
      region               = string
      workspace_key_prefix = optional(string)
      dynamodb_table       = string
    })
  })
}
variable "vault_endpoint" {
  type        = string
  description = "Endpoint of Vault environment"
  default     = "https://vault.calvineotieno.com"
}

variable "vault_token" {
  type        = string
  description = "Vault token used to authenticate to Vault"
  sensitive   = true
  default     = "hvs.ylofc7HgTExampletokenfake"
}
variable "region" {
  description = "AWS regions"
  default     = "eu-west-1"
}
variable "gitlab_domain" {
  description = "The domain name of your gitlab."
  default     = "gitlab.com"
}

variable "gitlab_project_id" {
  description = "The pipeline ID to authorize to auth with Vault"
  default     = "34733541"
}

variable "gitlab_pipeline_aws_assume_role" {
  description = "The AWS arn role for Vault to assume for AWS auth backend"
  default     = "arn:aws:iam::1234567890:role/gitlab_pipeline_aws_assume_role"
}
variable "project_name" {
  description = "Project name."
  default     = "recipe-app-api-proxy"
}

variable "gitlab_project_branch" {
  description = "The pipeline project branch to authorize to auth with Vault"
  default     = "main"
}

variable "aws_secret_default_ttl" {
  description = "The default lease ttl for AWS secret engine (default: 10min)"
  default     = 600
}

variable "aws_secret_max_ttl" {
  description = "The max lease ttl for AWS secret engine (default: 15min)"
  default     = 900
}

variable "jwt_token_max_ttl" {
  description = "The token max ttl for JWT auth backend (default: 15min)"
  default     = 900
}

variable "jwt_auth_tune_default_ttl" {
  description = "The tune default lease ttl for JWT auth backend (default: 10min)"
  default     = "10m"
}
variable "jwt_auth_tune_max_ttl" {
  description = "The tune max lease ttl for JWT auth backend (default: 15min)"
  default     = "15m"
}

variable "bound_audiences" {
  description = "List of aud claims to match against."
  type        = set(string)
  default     = ["https://gitlab.com"]
}
