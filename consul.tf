resource "helm_release" "consul" {
  name      = "consul"
  chart     = "consul"
  repository = "https://helm.releases.hashicorp.com"
  namespace = kubernetes_namespace.consul.metadata.0.name
  version    = "1.1.1"

  values = [
    templatefile("consul-helm/values.tmpl", { replicas = var.consul_node_count })
  ]
}
