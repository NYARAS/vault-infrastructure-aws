
# setup the mount point for the Root CA
resource "vault_mount" "pki" {
 path        = "pki"
 type        = "pki"
 description = "Network Root CA Mount"
 default_lease_ttl_seconds = 86400
 max_lease_ttl_seconds     = 315360000
}

# create the actual root CA Cert and key
resource "vault_pki_secret_backend_root_cert" "pon_root_g1" {
 backend     = vault_mount.pki.path
 type        = "internal"
 common_name = "Network Root G1"
 ttl         = 315360000
 issuer_name = "root-g1"
 key_bits    = 4096
}

# write this certificate to the terraform folder so we can use it elsewhere
resource "local_file" "pon_root_g1_cert" {
 content  = vault_pki_secret_backend_root_cert.pon_root_g1.certificate
 filename = "root_ca_g1.crt"
}

# optional: show this back to the user at runtime
output "root_ca_certificate" {
 value = vault_pki_secret_backend_root_cert.pon_root_g1.certificate
}

# the backend issuer is the element of the vault pki that enables people to requests issuing certs against this root 
resource "vault_pki_secret_backend_issuer" "pon_root_g1" {
 backend                        = vault_mount.pki.path
 issuer_ref                     = vault_pki_secret_backend_root_cert.pon_root_g1.issuer_id
 issuer_name                    = vault_pki_secret_backend_root_cert.pon_root_g1.issuer_name
 revocation_signature_algorithm = "SHA256WithRSA"
}

# the backend role is the api parameters that are allowed to be used when signing issuing certs
resource "vault_pki_secret_backend_role" "role" {
 backend          = vault_mount.pki.path
 name             = "root-sign-issuing-role"
 allow_ip_sans    = true
 key_type         = "rsa"
 key_bits         = 4096
 allow_subdomains = true
 allow_any_name   = true
}


# these config URLs are part of the vault pki ecosystem that clients can use to do ongoing checks that certs issued by this CA are not revoked before their expiry time 
resource "vault_pki_secret_backend_config_urls" "config-urls" {
 backend                 = vault_mount.pki.path
 issuing_certificates    = ["http://vault.calvineotieno.com:8200/v1/pki/ca"]
 crl_distribution_points = ["http://vault.calvineotieno.com:8200/v1/pki/crl"]
}

# this is establishing the vault mountpoint for the issuing certificate authority
resource "vault_mount" "pki_int" {
 path        = "pki_int"
 type        = "pki"
 description = "Problem of Network Issuing CA Mount"

 default_lease_ttl_seconds = 86400
 max_lease_ttl_seconds     = 157680000
}

# here we build a CSR (key never leaves vault) for that issuing CA
resource "vault_pki_secret_backend_intermediate_cert_request" "csr-request" {
 backend     = vault_mount.pki_int.path
 type        = "internal"
 common_name = "neuronsw-Issuing-G1"
 key_bits    = 4096
}
