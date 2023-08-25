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
