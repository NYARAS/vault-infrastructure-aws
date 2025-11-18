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

variable "vault_node_count" {
  description = "The number of vault replicas to run."
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

variable "trust_principals" {
  description = "List of ARNs that can assume the role"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for arn in var.trust_principals : can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", arn))])
    error_message = "Each trust principal must be a valid AWS IAM Role ARN (e.g., arn:aws:iam::123456789012:role/role-name)."
  }
}

variable "pipeline_policy_actions" {
  type        = list(string)
  description = "List of IAM actions allowed for the pipeline policy"
  default = [
    "s3:*",
    "dynamodb:*",
    "ec2:*",
    "rds:*",
    "eks:DescribeCluster",
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:PutImage",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload"
  ]
}
