resource "helm_release" "vault" {
  depends_on = [helm_release.consul]
  name      = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace = kubernetes_namespace.vault.metadata.0.name
  version   = "0.23.0"
  values = [
    templatefile("vault-helm/values.tmpl", { replicas = var.vault_node_count })
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
