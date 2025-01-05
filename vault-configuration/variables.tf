variable "DB_USER" {
  description = "postgresql username"
  default = "postgres"
}

variable "DB_PASSWORD" {
  description = "postgresql password"
  default = "password"
}

variable "DB_URL" {
  description = "postgresql URL"
  default = "postgres.default:5432"
}

variable "DB" {
  description = "postgresql URL"
  default = "test"
}

variable "vault_endpoint" {
  type = string
  description = "Endpoint of Vault environment"
}

variable "vault_token" {
  type = string
  description = "Vault token used to authenticate to Vault"
  sensitive = true
}
