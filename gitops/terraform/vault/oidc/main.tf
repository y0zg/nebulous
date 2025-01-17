data "vault_generic_secret" "vault_oidc_secrets" {
  path = "secret/admin/oidc-clients/vault"
}

variable "vault_redirect_uris" {
  type = list(string)
}

resource "vault_jwt_auth_backend" "keycloak_oidc" {
  description        = "jwt backend for vault oidc authentication"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://keycloak.<AWS_HOSTED_ZONE_NAME>/auth/realms/kubefirst"
  oidc_client_id     = "vault"
  oidc_client_secret = data.vault_generic_secret.vault_oidc_secrets.data["VAULT_CLIENT_SECRET"]
  default_role       = "developer"
}

resource "vault_jwt_auth_backend_role" "admin" {
  backend         = vault_jwt_auth_backend.keycloak_oidc.path
  role_name       = "admin"
  token_policies  = ["admin"]
  user_claim      = "sub"
  role_type       = "oidc"
  bound_audiences = ["vault"]
  allowed_redirect_uris = var.vault_redirect_uris
}

resource "vault_jwt_auth_backend_role" "developer" {
  backend         = vault_jwt_auth_backend.keycloak_oidc.path
  role_name       = "developer"
  token_policies  = ["developer"]
  user_claim      = "sub"
  role_type       = "oidc"
  bound_audiences = ["vault"]
  allowed_redirect_uris = var.vault_redirect_uris
}
