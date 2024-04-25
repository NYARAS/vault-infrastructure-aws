resource "vault_mount" "internal" {
  path        = "internal"
  type        = "kv-v2"
  description = "KV2 Secrets Engine for Test postgresql DB."
}


resource "vault_generic_secret" "test" {
  path = "${vault_mount.internal.path}/testdb/postgresql"

  data_json = <<EOT
{
  "username": "${var.DB_USER}",
  "password": "${var.DB_PASSWORD}"
}
EOT
}


// Enable PSQL database secret engine
resource "vault_mount" "db" {
  path = "postgresql"
  type = "database"
  description = "Dynamic Secrets Engine for Test Postgresql DB."
}


// Configure database secret engine connection [PSQL]
resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.db.path
  name          = "postgresql"
  allowed_roles = ["service-write", "dev-read"]

  postgresql {
    connection_url = "postgresql://${var.DB_USER}:${var.DB_PASSWORD}@${var.DB_URL}/${var.DB}?sslmode=disable"
    
  }
}

resource "vault_database_secret_backend_role" "postgres_service_write" {
  backend = vault_mount.db.path
  name    = "service-write"
  db_name = vault_database_secret_backend_connection.postgres.name

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}';",
    "GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]


  revocation_statements = [
    "REVOKE ALL ON ALL TABLES IN SCHEMA public FROM \"{{name}}\";",
    "DROP ROLE \"{{name}}\";",
  ]

  default_ttl = 864000 // 10 days
  max_ttl     = 864000 // 10 days
}

resource "vault_database_secret_backend_role" "postgres_dev_read" {
  backend = vault_mount.db.path
  name    = "dev-read"
  db_name = vault_database_secret_backend_connection.postgres.name

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
  ]


  revocation_statements = [
    "REVOKE ALL ON ALL TABLES IN SCHEMA public FROM \"{{name}}\";",
    "DROP ROLE \"{{name}}\";",
  ]


  default_ttl = 2592000 // 30 days
  max_ttl     = 2592000 // 30 days
}


resource "vault_policy" "reader_policy" {
  name = "reader"
  policy = data.vault_policy_document.reader_policy.hcl
}

resource "vault_policy" "test-app_ro" {
  name   = "test-app-ro"
  policy = file("policies/test-app-ro.hcl")
}


resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_role" "app" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "app"
  bound_service_account_names      = ["app"]
  bound_service_account_namespaces = ["app"]
  token_ttl                        = 86400
  token_policies                   = ["reader"]
}

resource "vault_kubernetes_auth_backend_role" "test-app-ro" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "test-app"
  bound_service_account_names      = ["test-app-sa"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 86400
  token_policies                   = ["test-app-ro"]
}
