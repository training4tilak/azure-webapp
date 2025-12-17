module "function_app_linux_pe" {
  count  = var.peSubnetId != "" && var.deployLinuxApp ? 1 : 0
  source = "../privateEndpoint"

  peName       = "${var.functionAppName}-pe"
  location     = azurerm_linux_function_app.function_app_linux[0].location
  rgName       = azurerm_linux_function_app.function_app_linux[0].resource_group_name
  onlySubnetId = var.peSubnetId

  peServiceConnName = "${var.functionAppName}-psc"
  resourceId        = azurerm_linux_function_app.function_app_linux[0].id
  subResourceName   = "sites"
  privateDnsList    = var.pePrivateDnsList != null && length(var.pePrivateDnsList) > 0 ? var.pePrivateDnsList : tolist([data.azurerm_private_dns_zone.appService.id])
}

module "function_app_windows_pe" {
  count  = var.peSubnetId != "" && var.deployWindowsApp ? 1 : 0
  source = "../privateEndpoint"

  peName       = "${var.functionAppName}-pe"
  location     = azurerm_windows_function_app.function_app_windows[0].location
  rgName       = azurerm_windows_function_app.function_app_windows[0].resource_group_name
  onlySubnetId = var.peSubnetId

  peServiceConnName = "${var.functionAppName}-psc"
  resourceId        = azurerm_windows_function_app.function_app_windows[0].id
  subResourceName   = "sites"
  privateDnsList    = var.pePrivateDnsList != null && length(var.pePrivateDnsList) > 0 ? var.pePrivateDnsList : tolist([data.azurerm_private_dns_zone.appService.id])
}