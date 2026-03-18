output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.lz.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.lz.vault_uri
}

output "identity_resource_group_id" {
  description = "Resource ID of the identity resource group."
  value       = azurerm_resource_group.identity.id
}
