resource "helm_release" "csi" {
  name       = "csi"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = var.csi_helm_version

  set {
    name  = "enableSecretRotation"
    value = "true"
  }

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }
}

resource "helm_release" "vault" {
  depends_on = [
    helm_release.csi
    ]
  name      = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace = kubernetes_namespace.vault.metadata.0.name
  version   = "0.29.0"
  values = [
    templatefile(
      "vault-helm/values.tmpl",
      {
      "replicas" = var.vault_node_count
      "vault_server_host"              = var.vault_server_host
       kms_key_id              = aws_kms_key.vault.key_id
       region = var.region
       vault_iam_role_arn      = module.vault_service_account_role.iam_role_arn
      }
      )
  ]
}

data "kubernetes_service" "vault_svc" {
  depends_on = [
    helm_release.vault
  ]

  metadata {
    namespace = "vault"
    name      = "vault-ui"
  }
}
resource "aws_iam_policy" "vault_service_account_policy" {
  name        = var.service_account_policy_name
  path        = "/"
  description = "Service account policy for Vault in EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.vault.arn
      }
    ]
  })

  tags = {
    Name = var.service_account_policy_name
  }
}

# AWS IAM role used for the Vault service account
module "vault_service_account_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = var.service_account_role_name
  role_policy_arns = {
    vault_service_account_policy = aws_iam_policy.vault_service_account_policy.arn
  }

  oidc_providers = {
    default = {
      provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:vault"]
    }
  }

  tags = {
    Name = var.service_account_role_name
  }
}

resource "aws_kms_key" "vault" {
  description = "Used for Vault."
}

resource "aws_kms_alias" "vault" {
  name          = "alias/vault"
  target_key_id = aws_kms_key.vault.key_id
}
