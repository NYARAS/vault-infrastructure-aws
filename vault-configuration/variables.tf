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


// Approle
variable "component" {
  description = "The component for which this approle exists."
  type        = string
}
variable "deployment_identifier" {
  type        = string
  description = "An identifier for this instantiation."
}

variable "backend" {
  type        = string
  description = "The path of the backend for the approle. Uses the default approle backend by default."
  default     = null
}

variable "role_name" {
  type        = string
  description = "The name of the approle. Takes precedence over the default role name generation and `role_name_prefix`."
  default     = null
}
variable "role_name_prefix" {
  type        = string
  description = "The name prefix of the approle. When provided, used to prefix the default role name generation."
  default     = null
}

variable "bind_secret_id" {
  type        = bool
  description = "Whether or not to require secret_id to be presented when logging in using this AppRole. Defaults to true."
  default     = null
}

variable "secret_id_bound_cidrs" {
  type        = list(string)
  description = "If set, specifies blocks of IP addresses which can perform the login operation."
  default     = null
}
variable "secret_id_num_uses" {
  type        = number
  description = "The number of times any particular SecretID can be used to fetch a token from this AppRole, after which the SecretID will expire. A value of zero will allow unlimited uses."
  default     = null
}
variable "secret_id_ttl" {
  type        = number
  description = "The number of seconds after which any SecretID expires."
  default     = null
}

variable "token_ttl" {
  type        = number
  description = "The incremental lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time."
  default     = null
}
variable "token_max_ttl" {
  type        = number
  description = "The maximum lifetime for generated tokens in number of seconds. Its current value will be referenced at renewal time."
  default     = null
}
variable "token_period" {
  type        = number
  description = "If set, indicates that the token generated using this role should never expire. The token should be renewed within the duration specified by this value. At each renewal, the token's TTL will be set to the value of this field. Specified in seconds."
  default     = null
}
variable "token_policies" {
  type        = list(string)
  description = "List of policies to encode onto generated tokens. Depending on the auth method, this list may be supplemented by user/group/other values."
  default     = null
}
variable "token_bound_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks; if set, specifies blocks of IP addresses which can authenticate successfully, and ties the resulting token to these blocks as well."
  default     = null
}

variable "token_explicit_max_ttl" {
  type        = number
  description = "If set, will encode an explicit max TTL onto the token in number of seconds. This is a hard cap even if token_ttl and token_max_ttl would otherwise allow a renewal."
  default     = null
}
variable "token_num_uses" {
  type        = number
  description = "The maximum number of times a generated token may be used (within its lifetime); 0 means unlimited."
  default     = null
}
variable "token_type" {
  type        = string
  description = "The type of token that should be generated. Can be service, batch, or default to use the mount's tuned default (which unless changed will be service tokens). For token store roles, there are two additional possibilities: default-service and default-batch which specify the type to return unless the client requests a different type at generation time."
  default     = null
}

variable "default_secret_id_cidr_list" {
  type        = list(string)
  description = "If set, specifies blocks of IP addresses which can perform the login operation using the default SecretID."
  default     = null
}

variable "cn" {}
variable "ip_sans" {
  default = []
}

variable "root_role_name" {
  default = "root-sign-issuing-role"
}

variable "issuing_certificates_urls" {
  type    = list(string)
  default = []
}

variable "crl_distribution_points" {
  type    = list(string)
  default = []
}

variable "secret_backend_intermediate_cn" {
  default = "calvine-Issuing"
}
variable "secret_backend_root_sign_intermediate_cn" {
  default = "calvine-Issuing"
}
variable "secret_backend_issuer_name" {
  default = "calvine-Issuing"
}

variable "allowed_domains" {
  type    = list(string)
  default = ["calvine.com"]
}

variable "vault_pki_secret_backend_role_name" {
  default = "calvine-dot-com"
}
