output "linux_function_app" {
  value       = var.deployLinuxApp ? azurerm_linux_function_app.function_app_linux[0] : null
  description = "Azure Linux Function App object if deployed"
}

output "windows_function_app" {
  value       = var.deployWindowsApp ? azurerm_windows_function_app.function_app_windows[0] : null
  description = "Azure Windows Function App object if deployed"
}