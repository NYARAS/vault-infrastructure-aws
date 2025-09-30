resource "vault_jwt_auth_backend" "github_oidc" {
  description        = "Binds an OIDC JWT auth backend to GitHub Actions."
  path               = var.oidc_auth_backend_path
  oidc_discovery_url = var.github_identity_provider
  bound_issuer       = var.github_identity_provider
}

locals {
  additional_claims = { for binding in var.oidc_bindings : binding.vault_role_name => binding.additional_claims }
}


resource "vault_jwt_auth_backend_role" "github_oidc_role" {
  # Converts the list of objects into a map of Vault role name => whole object.
  # This uniquely identifies each resource by its Vault role name.
  # This allows Terraform to properly track state across items in the for loop.
  for_each = { for binding in var.oidc_bindings : binding.vault_role_name => binding }

  role_type = "jwt"
  backend   = vault_jwt_auth_backend.github_oidc.path

  role_name       = each.value.vault_role_name # Equivalent to each.key but explicitly using value for demonstration purposes
  user_claim      = each.value.user_claim != null ? each.value.user_claim : var.default_user_claim
  bound_audiences = each.value.audience
  # Use bound_claims.sub instead of bound_subject, even though both evaluate the "sub" claim in the JWT.
  #
  # bound_subject is syntactic sugar around bound_claims.sub and doesn't play well with terraform state in the
  # current version of the provider.
  # Using `bound_subject` alone results in continual terraform drift, as Vault will generate bound_claims.sub
  # in its data but re-running an apply will remove bound_claims.sub.
  # So, either declare both to be the same value or just use bound_claims.sub.
  # We're doing the latter.
  bound_subject = ""
  # Add any additional claims a user has entered.
  # Ensure the bound_subject parameter overwrites any other sub declarations (second map in merge overwrites existing key if present).
  bound_claims      = local.additional_claims[each.key] != null ? merge(local.additional_claims[each.key], { sub = each.value.bound_subject }) : { sub = each.value.bound_subject }
  bound_claims_type = "glob"

  token_policies = each.value.vault_policies
  token_ttl      = each.value.ttl != null ? each.value.ttl : var.default_ttl
  token_type     = var.token_type_gh
}


variable "default_ttl" {
  type        = number
  description = "The default incremental time-to-live for generated tokens, in seconds."
  default     = 300 # 5 minutes
}

variable "default_user_claim" {
  type        = string
  description = "This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Consider the impact on [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows#how-the-token-works-with-reusable-workflows) if you are thinking of changing this value from the default."
  default     = "job_workflow_ref"
}

variable "github_identity_provider" {
  type        = string
  description = "The JWT authentication URL used for the GitHub OIDC trust configuration. If you are an Enteprise Cloud account, you should configure a [unique token URL](https://docs.github.com/en/enterprise-cloud@latest/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#switching-to-a-unique-token-url) and set the result on this variable. If you are an Enterprise Server organization, you should provide a URL in the format: `https://HOSTNAME/_services/token`. This requires GitHub Enterprise Server version 3.5 or higher. See <https://docs.github.com/en/enterprise-server@latest/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#adding-the-identity-provider-to-hashicorp-vault>."
  default     = "https://token.actions.githubusercontent.com"
}

variable "oidc_auth_backend_path" {
  type        = string
  description = "The path to mount the OIDC auth backend."
  default     = "github-actions"
}

variable "oidc_bindings" {
  type = list(object({
    audience          = set(string),
    vault_role_name   = string,
    bound_subject     = string,
    vault_policies    = set(string),
    user_claim        = optional(string),
    additional_claims = optional(map(string)),
    ttl               = optional(number),
  }))

  description = <<-EOT
    A list of OIDC JWT bindings between GitHub repos and Vault roles. For each entry, you must include:

      `audience`: By default, this must be the URL of the repository owner (e.g. `https://github.com/digitalocean`). This can be customized with the `jwtGithubAudience` parameter in [hashicorp/vault-action](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-hashicorp-vault#requesting-the-access-token) . This is the bound audience (`aud`) field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) .

      `vault_role_name`: The name of the Vault role to generate under the OIDC auth backend.

      `bound_subject`: This is what is set in the `sub` field from [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . The bound subject can be constructed from various filters, such as a branch, tag, or specific [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) . See [GitHub's documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#example-subject-claims) for examples.

      `vault_policies`: A list of Vault policies you wish to grant to the generated token.

      `user_claim`: **Optional**. This is how you want Vault to [uniquely identify](https://www.vaultproject.io/api/auth/jwt#user_claim) this client. This will be used as the name for the Identity entity alias created due to a successful login. This must be a field present in the [GitHub JWT token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Defaults to the `default_user_claim` variable if not provided. Consider the impact on [reusable workflows](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/using-openid-connect-with-reusable-workflows#how-the-token-works-with-reusable-workflows) if you are thinking of changing this value from the default.

      `additional_claims`: **Optional**. Any additional `bound_claims` to configure for this role. Claim keys must match a value in [GitHub's OIDC token](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token) . Do not use this field for the `sub` claim. Use the `bound_subject` parameter instead.

      `ttl`: **Optional**. The default incremental time-to-live for the generated token, in seconds. Defaults to the `default_ttl` value but can be individually specified per binding with this value.

    EOT
}

variable "token_type_gh" {
  type        = string
  default     = "batch"
  description = "The type of token to generate. This can be either `batch` or `service`. See <https://developer.hashicorp.com/vault/api-docs/auth/jwt#token_type> for more information."
}

output "auth_backend_path" {
  description = "The path of the generated auth method. Use with a `vault_auth_backend` data source to retrieve any needed attributes from this resource."
  value       = vault_jwt_auth_backend.github_oidc.path
}

output "oidc_bindings_names" {
  description = "The Vault role names generated for each OIDC binding provided. This is a reflection of the `vault_role_name` value of each item in `oidc-bindings`."
  value       = values(vault_jwt_auth_backend_role.github_oidc_role)[*].role_name
}