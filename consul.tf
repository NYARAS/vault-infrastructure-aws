resource "helm_release" "consul" {
  name      = "consul"
  chart     = "consul-helm"
  namespace = kubernetes_namespace.consul.metadata.0.name
  version   = "v0.18.0"

  values = [
    templatefile("consul/values.tmpl", { replicas = var.consul_node_count })
  ]
}
