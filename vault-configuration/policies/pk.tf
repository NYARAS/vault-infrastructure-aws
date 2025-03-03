resource "vault_policy" "pki-admin-vault-policy" {
  name = "pki-admin-vault-policy"

  policy = <<EOT
## place to store account details for automation towards the devices
path "network-automation/+/device-creds" {
  capabilities = ["create", "update"]
}
path "network-automation/+/device-creds" {
  capabilities = ["read","list"]
}
## place to store certificates we generate for the devices
path "network-automation/+/device-certs" {
  capabilities = ["create", "update"]
}
path "network-automation/+/device-certs" {
  capabilities = ["read","list"]
}
## Vault TF provider requires ability to create a child token
path "auth/token/create" {  
  capabilities = ["create", "update", "sudo"]  
}
EOT
}

