locals {

  # ───────────────────────────────────────────── #
  # Effective Resource Group Name                 #
  # - Uses the resource group name provided       #
  #   via input variable                          #
  # ───────────────────────────────────────────── #
  resourceGroupName = var.resourceGroupName

  # ───────────────────────────────────────────── #
  # Effective Resource Group Location             #
  # - Retrieves the location of the existing      #
  #   resource group to ensure consistency for    #
  #   dependent resources                         #
  # ───────────────────────────────────────────── #
  resourceGroupLocation = var.resourceGroupLocation


  # ───────────────────────────────────────────── #
  # These are used when authentication is enabled #
  # ───────────────────────────────────────────── #
  azureAdIssuer       = "https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/v2.0" # The Azure AD tenant authentication endpoint (issuer URL).
  appClientSecretName = "AzureAD__ClientSecret"                                                        # Name of the secret in Key Vault that contains the Azure AD application client secret.

}
