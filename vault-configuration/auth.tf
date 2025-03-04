resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "pki-admin" {
  path                 = "auth/${vault_auth_backend.userpass.path}/users/pki-admin"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "token_policies": ["pki-admin-vault-policy"],
  "password": "${var.password}"
}
EOT
}

variable "password" {
  
}
