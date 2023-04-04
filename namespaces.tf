resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}
