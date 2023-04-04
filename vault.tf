resource "helm_release" "vault" {
  name      = "vault"
  chart     = "vault-helm"
  namespace = kubernetes_namespace.vault.metadata.0.name
  version   = "v0.4.0"
  values = [
    templatefile("vault/values.tmpl", { replicas = var.vault_node_count })
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
