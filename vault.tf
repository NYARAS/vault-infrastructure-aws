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


// TODO - Move to vault configuration

data "kubernetes_service_account" "vault_auth" {
  depends_on = [helm_release.vault]

  metadata {
    name = "vault"
  }
}

data "kubernetes_secret" "vault_auth" {
  depends_on = [helm_release.vault]

  metadata {
    name = data.kubernetes_service_account.vault_auth.default_secret_name
  }
}

resource "vault_auth_backend" "kubernetes" {
  depends_on = [helm_release.vault]
  type       = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  depends_on             = [helm_release.vault]
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = local.kubernetes_host
  kubernetes_ca_cert     = data.kubernetes_secret.vault_auth.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault_auth.data.token
  disable_iss_validation = "true"
}
