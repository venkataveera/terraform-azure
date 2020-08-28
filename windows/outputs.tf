
# Retrieve the Public IP address
data azurerm_public_ip test_public_ip {
    name = azurerm_public_ip.terraform_publicip.name
    resource_group_name = azurerm_resource_group.terraform_resource_group.name
    depends_on = [azurerm_virtual_machine.terraform_vm]
}

output "ip_address" {
    value = [data.azurerm_public_ip.test_public_ip.ip_address]
}