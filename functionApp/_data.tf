# ───────────────────────────────────────────────────────────── #
# App Service Module - Data Sources                             #
# These data sources retrieve existing Azure resources needed   #
# for the App Service deployment, such as Resource Groups,      #
# Virtual Networks, Subnets, and Storage Accounts.              #
# ───────────────────────────────────────────────────────────── #

#Private DNS Zone
data "azurerm_private_dns_zone" "appService" {
  provider            = azurerm.networkingsub
  name                = "privatelink.azurewebsites.net"
  resource_group_name = "Meadowbrook_Networking"
}

# Terraform Client
data "azuread_client_config" "current" {
}