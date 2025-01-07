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
variable "vault_node_count" {
  description = "The number of vault replicas to run."
  default     = "1"
}

variable "consul_node_count" {
  description = "The number of consul replicas to run."
  default     = "1"
}

variable "csi_helm_version" {
  type        = string
  description = "Secrets Store CSI Driver Helm chart version"
  default     = "1.2.4"
}

variable "namespace" {
  default = "vault"
}

variable "vault_server_host" {
  type        = string
  description = "Domain to access vault ui."
  default     = "vault.example.com"
}

variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-1"
}

variable "service_account_policy_name" {
  description = "(Optional) The name of the IAM policy for the Vault service account. Defaults to `vault-service-account-policy`."
  type        = string
  default     = "vault-service-account-policy"
}

variable "service_account_role_name" {
  description = "(Optional) The name of the IAM role for the Vault service account. Defaults to `vault-service-account-role`."
  type        = string
  default     = "vault-service-account-role"
}

variable "gitlab_pipeline_aws_assume_role" {
  default = "gitlab-pipeline-aws-assume-role"
}

variable "aws_acm" {
  type        = string
  description = "AWS Certificate Manager ARN."
}
