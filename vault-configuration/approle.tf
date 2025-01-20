resource "vault_approle_auth_backend_role" "role" {
  backend   = var.backend
  role_name = local.resolved_role_name

  bind_secret_id = var.bind_secret_id

  secret_id_bound_cidrs = var.secret_id_bound_cidrs
  secret_id_num_uses    = var.secret_id_num_uses
  secret_id_ttl         = var.secret_id_ttl

  token_ttl              = var.token_ttl
  token_max_ttl          = var.token_max_ttl
  token_period           = var.token_period
  token_policies         = var.token_policies
  token_bound_cidrs      = var.token_bound_cidrs
  token_explicit_max_ttl = var.token_explicit_max_ttl
  token_num_uses         = var.token_num_uses
  token_type             = var.token_type
}

# Add token policies to role

resource "vault_approle_auth_backend_role_secret_id" "default" {
  count = var.bind_secret_id != false ? 1 : 0

  backend = var.backend

  role_name = vault_approle_auth_backend_role.role.role_name

  cidr_list = var.default_secret_id_cidr_list

  metadata = jsonencode({
    component : var.component,
    deployment_identifier : var.deployment_identifier,
    label : "default"
  })
}
