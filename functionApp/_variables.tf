# ─────────────────────────────────────────────────────────────── #
# App Service Module - Input Variables                            #
# These variables define configuration inputs such as networking, #
# scaling, runtime settings, storage mounts, and security options #
# ─────────────────────────────────────────────────────────────── #

# ───────────────────────────────────────────── #
# Resource Group and Tag Configuration          #
# ───────────────────────────────────────────── #

variable "resourceGroupName" {
  description = "The name of the resource group to create or use for deploying AI Foundry resources."
  type        = string
  default     = null
}

variable "resourceGroupLocation" {
  description = "The location of the resource group to deploy resources into."
  type        = string
  default     = "eastus2"
}

variable "tags" {
  description = "A map of key-value pairs to apply as tags to all resources created by this module."
  type        = map(string)
  default     = {}
}

# ───────────────────────────────────────────── #
# Networking Configuration                      #
# ───────────────────────────────────────────── #
variable "peSubnetId" {
  description = "(Optional) ID of the subnet within the specified Virtual Network used for the Function App's private endpoint. Leave null to disable private networking."
  type        = string
  default     = null
}


variable "pePrivateDnsList" {
  description = "(Optional) A list of Private DNS Zone IDs to associate with the private endpoint."
  type        = list(string)
  default     = []
}

variable "networkingSub" {
  description = "Subscription ID of the (Shared-Services-Prod) where the Private DNS Zones are located"
  type        = string
}

variable "appOutboundSubnetId" {
  description = "(Optional) The ID of the virtual network subnet to integrate the App with (This allows the app to access resources within a private network). Leave empty to disable VNet integration."
  type        = string
  default     = ""
}

# ───────────────────────────────────────────── #
# App Service Plan Configuration               #
# ───────────────────────────────────────────── #
variable "appServicePlanSku" {
  description = <<EOT
The SKU size of the App Service Plan, specifying tier and size:
- Free: F1
- Shared: D1
- Basic: B1, B2, B3
- Standard: S1, S2, S3
- PremiumV2: P1v2, P2v2, P3v2
- PremiumV3: P0v3, P1v3, P2v3, P3v3
- Isolated: I1, I2, I3
EOT
  type        = string
  default     = "P0v3"
}

variable "existingServicePlanId" {
  description = "Optional. The ID of an existing App Service Plan to use for the Function App."
  type        = string
  default     = ""
}

variable "appServicePlanOsType" {
  description = "The OS type for the App Service Plan. Allowed values: Windows, Linux."
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Windows", "Linux"], var.appServicePlanOsType)
    error_message = "appServicePlanOsType must be either 'Windows' or 'Linux'."
  }
}

variable "appServicePlanWorkerCount" {
  description = "Number of workers (instances) for the App Service Plan."
  type        = number
  default     = 2
}

variable "appServicePlanZoneBalancingEnabled" {
  description = "Enable zone redundancy to distribute instances across availability zones (if supported)."
  type        = bool
  default     = false
}

# ───────────────────────────────────────────── #
#           Entra Authentication                #
# ───────────────────────────────────────────── #
variable "appClientId" { # Needs to the Present to turn on authentication
  description = "The Client ID of the Azure AD application used for authentication."
  type        = string
  default     = ""
}

variable "appClientSecretKvId" { # Store this in a Key Vault and then pass the Versionless id of the secret  e.g. @Microsoft.KeyVault(SecretUri=$ {azurerm_key_vault_secret.appClientSecret.versionless_id})
  description = "The Key Vault Secret ID of the Azure AD application client secret value used for authentication."
  type        = string
  default     = ""
}

# ───────────────────────────────────────────── #
# Function App Configuration                    #
# ───────────────────────────────────────────── #
variable "functionAppName" {
  description = "The name of the Function App."
  type        = string
  default     = "functionapp"
}

variable "functionAppAppSettings" {
  description = "Map of application settings for the Function App."
  type        = map(string)
  default     = {}
}

variable "functionAppExtensionversion" {
  type    = string
  default = "~4"
}

variable "publicNetworkAccessEnabled" {
  description = "Enable or disable public network access. Set to false for private endpoints only."
  type        = bool
  default     = false
}

variable "functionAppClientCertificateEnabled" {
  description = "Enforce client certificates on HTTPS requests."
  type        = bool
  default     = false
}

variable "clientCertificateEnabled" {
  description = "Enforce client certificates on HTTPS requests."
  type        = bool
  default     = true
}

# ───────────────────────────────────────────── #
# App Deployment Control Flags                 #
# ───────────────────────────────────────────── #
variable "deployLinuxApp" {
  description = "When true, deploy the Linux App Service."
  type        = bool
  default     = false
}

variable "deployWindowsApp" {
  description = "When true, deploy the Windows App Service."
  type        = bool
  default     = false
}

variable "linuxPythonVersion" {
  type    = string
  default = "3.13"
}


variable "dotnetVersion" {
  description = ".Net runtime version, e.g., '8.0', '9.0'"
  type        = string
  default     = "9.0"
}

variable "dotnetVersionWin" {
  description = "Windows Function .Net runtime version, e.g., 'v8.0', 'v9.0'"
  type        = string
  default     = "v9.0"
}

variable "dotnetIsolated" {
  type        = bool
  default     = false
  description = "Set to true to enable .NET isolated runtime for the Function App when using dotnet as the runtime."
}

variable "powerShellVersion" {
  type        = string
  default     = "7.4"
  description = "PowerShell Core version for the Function App."
}


variable "nodeVersion" {
  description = "Node.js runtime version, e.g., '20LTS', '22'"
  type        = string
  default     = "22"
}

variable "nodeVersionWin" {
  description = "Node.js runtime version, e.g., '~20', '~22'"
  type        = string
  default     = "~22"
}

variable "runtime" {
  type        = string
  description = "Runtime to use for the Function App"
  default     = "node"
  validation {
    condition     = contains(["python", "dotnet", "powershell", "node"], var.runtime)
    error_message = "Runtime must be one of: python, dotnet, powershell, node."
  }
}

# ───────────────────────────────────────────── #
# Function App Storage                          #
# ───────────────────────────────────────────── #
variable "functionAppStorageAccountName" {
  type    = string
  default = ""
}

variable "functionAppStorageAccessKey" {
  type    = string
  default = ""
}

# ───────────────────────────────────────────── #
# Application Insights                          #
# ───────────────────────────────────────────── #
variable "appInsightsConnectionString" {
  type        = string
  description = "Connection string for Application Insights"
  default     = ""
}