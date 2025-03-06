resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  description               = "Calvine Devops Root CA Mount"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Calvine DevOps Root"
  ttl         = 315360000
  issuer_name = "root-g1"
  key_bits    = 4096
}

resource "vault_pki_secret_backend_issuer" "root" {
  backend                        = vault_mount.pki.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.root.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.root.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = var.root_role_name
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allow_subdomains = true
  allow_any_name   = true
}

resource "vault_pki_secret_backend_config_urls" "config-urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = var.issuing_certificates_urls
  crl_distribution_points = var.crl_distribution_points
}

resource "vault_mount" "pki_int" {
  path        = "pki_int"
  type        = "pki"
  description = "Calvine Issuing CA Mount"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "csr-request" {
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = var.secret_backend_intermediate_cn
  key_bits    = 4096
}

resource "vault_pki_secret_backend_root_sign_intermediate" "issuing" {
  backend     = vault_mount.pki.path
  common_name = var.secret_backend_root_sign_intermediate_cn
  csr         = vault_pki_secret_backend_intermediate_cert_request.csr-request.csr
  format      = "pem_bundle"
  ttl         = 15480000
  issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "issuing" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.issuing.certificate
}

resource "vault_pki_secret_backend_issuer" "issuing" {
  backend     = vault_mount.pki_int.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.issuing.imported_issuers[0]
  issuer_name = var.secret_backend_issuer_name
}

resource "vault_pki_secret_backend_role" "issuing_role" {
  backend          = vault_mount.pki_int.path
  issuer_ref       = vault_pki_secret_backend_issuer.issuing.issuer_ref
  name             = var.vault_pki_secret_backend_role_name
  ttl              = 86400
  max_ttl          = 2592000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = var.allowed_domains
  allow_subdomains = true
}
