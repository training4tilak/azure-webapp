
# ───────────────────────────────────────────────────────────── #
# Function App Module - Main Resource Definitions               #
# These resources deploy Azure Function Apps (Linux/Windows)    #
# with options for identity, networking, logging, and settings. #
# Designed for secure and scalable serverless compute.          #
# Compatible with AzureRM Provider v4.32.0+.                    #
# ───────────────────────────────────────────────────────────── #

resource "azurerm_storage_account" "function_storage" {
  count                    = var.functionAppStorageAccessKey == "" ? 1 : 0
  name                     = var.functionAppStorageAccountName
  resource_group_name      = local.resourceGroupName
  location                 = local.resourceGroupLocation
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# ───────────────────────────────────────────── #
# Function App Hosting Plan                     #
# Defines the Hosting Plan used by the Function #
# App for both Linux and Windows environments.  #
# ───────────────────────────────────────────── #

resource "azurerm_service_plan" "function" {
  count               = var.existingServicePlanId == "" ? 1 : 0
  name                = "${var.functionAppName}-asp"
  location            = local.resourceGroupLocation
  resource_group_name = local.resourceGroupName
  os_type             = var.deployLinuxApp ? "Linux" : "Windows"
  sku_name            = var.appServicePlanSku
  tags                = var.tags
}

# ───────────────────────────────────────────── #
# Azure Function App Linux                      #
# Creates the Function App with app settings,   #
# site configuration, authentication, and logs. #
# ───────────────────────────────────────────── #
resource "azurerm_linux_function_app" "function_app_linux" {
  count                       = var.deployLinuxApp ? 1 : 0
  name                        = var.functionAppName
  location                    = local.resourceGroupLocation
  resource_group_name         = local.resourceGroupName
  service_plan_id             = azurerm_service_plan.function[0].id
  storage_account_name        = var.functionAppStorageAccessKey != "" ? var.functionAppStorageAccountName : azurerm_storage_account.function_storage[0].name
  storage_account_access_key  = var.functionAppStorageAccessKey != "" ? var.functionAppStorageAccessKey : azurerm_storage_account.function_storage[0].primary_access_key
  functions_extension_version = var.functionAppExtensionversion

  client_certificate_enabled                     = var.clientCertificateEnabled
  virtual_network_subnet_id                      = var.appOutboundSubnetId != "" ? var.appOutboundSubnetId : null
  public_network_access_enabled                  = var.publicNetworkAccessEnabled
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  https_only                                     = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(
    var.functionAppAppSettings,
    var.appClientId != "" ? {
      "${local.appClientSecretName}" = var.appClientSecretKvId
    } : {},
    var.runtime == "dotnet" && var.dotnetIsolated ? {
      "FUNCTIONS_WORKER_RUNTIME" = "dotnet-isolated"
    } : {}
  )


  site_config {
    ftps_state                             = "Disabled"
    http2_enabled                          = false
    minimum_tls_version                    = "1.2"
    always_on                              = true
    ip_restriction_default_action          = "Deny"
    scm_ip_restriction_default_action      = "Allow"
    application_insights_connection_string = var.appInsightsConnectionString != "" ? var.appInsightsConnectionString : null
    websockets_enabled                     = false
    vnet_route_all_enabled                 = var.appOutboundSubnetId != "" ? true : false

    dynamic "application_stack" {
      for_each = [1]
      content {
        python_version          = var.runtime == "python" ? var.linuxPythonVersion : null
        dotnet_version          = var.runtime == "dotnet" ? var.dotnetVersion : null
        powershell_core_version = var.runtime == "powershell" ? var.powerShellVersion : null
        node_version            = var.runtime == "node" ? var.nodeVersion : null
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.appClientId != "" ? [1] : []
    content {
      auth_enabled           = true
      require_authentication = true
      unauthenticated_action = "RedirectToLoginPage"

      active_directory_v2 {
        client_id                  = var.appClientId
        client_secret_setting_name = local.appClientSecretName
        tenant_auth_endpoint       = local.azureAdIssuer
        allowed_audiences          = ["api://${var.appClientId}"]
      }

      login {
        token_store_enabled = true
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # app_settings,
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  tags = var.tags
}


# ───────────────────────────────────────────── #
# Azure Function App Windows                    #
# Creates the Function App with app settings,   #
# site configuration, authentication, and logs. #
# ───────────────────────────────────────────── #
resource "azurerm_windows_function_app" "function_app_windows" {
  count                       = var.deployWindowsApp ? 1 : 0
  name                        = var.functionAppName
  location                    = local.resourceGroupLocation
  resource_group_name         = local.resourceGroupName
  service_plan_id             = azurerm_service_plan.function[0].id
  storage_account_name        = var.functionAppStorageAccessKey != "" ? var.functionAppStorageAccountName : azurerm_storage_account.function_storage[0].name
  storage_account_access_key  = var.functionAppStorageAccessKey != "" ? var.functionAppStorageAccessKey : azurerm_storage_account.function_storage[0].primary_access_key
  functions_extension_version = var.functionAppExtensionversion

  client_certificate_enabled                     = var.clientCertificateEnabled
  virtual_network_subnet_id                      = var.appOutboundSubnetId != "" ? var.appOutboundSubnetId : null
  public_network_access_enabled                  = var.publicNetworkAccessEnabled
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  https_only                                     = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(
    var.functionAppAppSettings,
    var.appClientId != "" ? {
      "${local.appClientSecretName}" = var.appClientSecretKvId
    } : {},
    var.runtime == "dotnet" ? {
      "FUNCTIONS_WORKER_RUNTIME" = "dotnet-isolated"
    } : {}
  )

  site_config {
    ftps_state                             = "Disabled"
    http2_enabled                          = false
    minimum_tls_version                    = "1.2"
    always_on                              = true
    ip_restriction_default_action          = "Deny"
    scm_ip_restriction_default_action      = "Allow"
    application_insights_connection_string = var.appInsightsConnectionString != "" ? var.appInsightsConnectionString : null
    websockets_enabled                     = false
    vnet_route_all_enabled                 = var.appOutboundSubnetId != "" ? true : false

    application_stack {
      dotnet_version          = var.runtime == "dotnet" ? var.dotnetVersionWin : null
      node_version            = var.runtime == "node" ? var.nodeVersionWin : null
      powershell_core_version = var.runtime == "powershell" ? var.powerShellVersion : null


    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.appClientId != "" ? [1] : []
    content {
      auth_enabled           = true
      require_authentication = true
      unauthenticated_action = "RedirectToLoginPage"

      active_directory_v2 {
        client_id                  = var.appClientId
        client_secret_setting_name = local.appClientSecretName
        tenant_auth_endpoint       = local.azureAdIssuer
        allowed_audiences          = ["api://${var.appClientId}"]
      }

      login {
        token_store_enabled = true
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # app_settings,
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }

  tags = var.tags
}