resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}
