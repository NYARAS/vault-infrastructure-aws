resource "vault_policy" "reader_policy" {
  name   = "reader"
  policy = data.vault_policy_document.reader_policy.hcl
}

resource "vault_policy" "test-app_ro" {
  name   = "test-app-ro"
  policy = file("policies/test-app-ro.hcl")
}


resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "test-app-ro" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "test-app"
  bound_service_account_names      = ["test-app"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 86400
  token_policies                   = ["test-app-ro"]
}
