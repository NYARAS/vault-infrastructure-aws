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
    helm_release.consul,
    helm_release.csi
    ]
  name      = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace = kubernetes_namespace.vault.metadata.0.name
  version   = "0.24.1"
  values = [
    templatefile(
      "vault-helm/values.tmpl",
      {
      "replicas" = var.vault_node_count
      "vault_server_host"              = var.vault_server_host
      "vault_acm_arn" = data.terraform_remote_state.eks.outputs.aws_acm_certificate_arn
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
