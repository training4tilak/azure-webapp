
# ⚙️ Azure Function App Terraform Module

## 📘 Overview

This module provisions **Azure Function Apps** for both **Linux** and **Windows** environments, based on conditional flags. It supports secure configurations, flexible runtime stacks, and integration with Azure services like Key Vault, Application Insights, and Virtual Networks.

## ✅ Features

- **Dual OS Support**: Deploys Linux or Windows Function Apps based on `deployLinuxApp` and `deployWindowsApp` flags.
- **Runtime Flexibility**: Supports Node.js, Python, .NET (isolated), and PowerShell runtimes.
- **Secure by Default**:
  - HTTPS-only traffic
  - Disabled FTP/WebDeploy basic auth
  - TLS 1.2 minimum
  - IP restrictions and VNet integration
  - System-assigned managed identity
- **Authentication**: Azure AD v2 integration with redirect login and token store.
- **Observability**: Application Insights integration via connection string.
- **Environment-Specific App Settings**: Dynamically merged from input variables.

## 📦 Resources Created

- `azurerm_linux_function_app` (conditional)
- `azurerm_windows_function_app` (conditional)
- `azurerm_service_plan`
- `azurerm_storage_account` (optional)
- `azurerm_application_insights` (optional)

## 🔧 Configuration Flags

| Variable                         | Description                                 | Default |
|----------------------------------|---------------------------------------------|---------|
| `deployLinuxApp`                 | Deploy Linux Function App                   | `false` |
| `deployWindowsApp`               | Deploy Windows Function App                 | `false` |
| `functionAppName`                | Name of the Function App                    | —       |
| `functionAppExtensionversion`    | Functions runtime version (e.g., `~4`)      | —       |
| `functionAppStorageAccessKey`    | Optional override for storage key           | `""`    |
| `functionAppStorageAccountName`  | Optional override for storage name          | `""`    |
| `appClientId`                    | Azure AD client ID for auth                 | `""`    |
| `appClientSecretKvId`            | Key Vault secret ID for client secret       | `""`    |
| `appOutboundSubnetId`            | Subnet ID for VNet integration              | `""`    |
| `appInsightsConnectionString`    | App Insights connection string              | `""`    |

## 🚀 Example Usage

```hcl
module "function_app" {
  source = "../../../__Azure-IaC-Modules/drop/_modules/functionApp"

  functionAppName               = lower("${var.tagApp}-${var.environment}-fun")
  appServicePlanSku             = "P0v3" # Example: Consumption plan
  functionAppStorageAccountName = lower("${var.tagApp}${var.environment}stg")
  functionAppStorageAccessKey   = "" # Leave empty to create storage account

  # App Settings
  functionAppAppSettings = {
    # "WEBSITE_RUN_FROM_PACKAGE" = "1" # Example
  }

  # Runtime
  deployWindowsApp = true
  runtime          = "node"
  nodeVersion      = "18"

  # Networking
  publicNetworkAccessEnabled  = false
  peSubnetId                  = azurerm_subnet.peSubnet.id
  appOutboundSubnetId         = ""                                                                     # Optional: provide subnet ID if needed
  appInsightsConnectionString = nonsensitive("${azurerm_application_insights.appi.connection_string}") # Optional: for logging

  # Auth
  appClientId         = "" # Optional: for Azure AD integration
  appClientSecretKvId = "" # Optional: for Azure AD integration, Key Vault Secret ID 

  # Resource Group
  resourceGroupName     = module.rgMain.resourceGroup.name
  resourceGroupLocation = module.rgMain.resourceGroup.location
  networkingSub         = var.networkingSub

  tags = local.tagsBaseline
}
```

## 🧪 Runtime Stack Support

| Runtime     | Linux Variable             | Windows Variable           |
|-------------|----------------------------|----------------------------|
| Node.js     | `nodeVersion`              | `nodeVersionWin`           |
| Python      | `linuxPythonVersion`       | (Not Compatible)                          |
| .NET        | `dotnetVersion`            | `dotnetVersionWin`         |
| PowerShell  | `powerShellVersion`        | `powerShellVersion`        |

## 🔐 Authentication

If `appClientId` is provided, Azure AD authentication is enabled with:

- Redirect to login for unauthenticated users
- Token store enabled
- Audience validation (`api://{appClientId}`)

## 🧪 Testing the Module

To test this module in isolation:

1. Clone the module repository or copy it into your Terraform project.
2. Create a `main.tf` that calls the module.
3. Create a `terraform.tfvars` using the provided `terraform.tfvars.sample`.
4. Run the following:

```bash
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

## 👤 Maintainer

This module is intended for internal AFGroup use. Designed for reuse across multiple environments with flexibility in mind.