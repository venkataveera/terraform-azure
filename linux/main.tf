# Configure the Microsoft Azure Provider
provider azurerm {
  # If you would like to use authentication through a Service Pricipal or 
  # a specific subscription/tenant uncomment below lines and update values
  #   subscription_id = var.azure_subscription_id
  #   client_id       = var.azure_client_id
  #   client_secret   = var.azure_client_secret
  #   tenant_id       = var.azure_tenant_id
  version = "=2.25.0"
  features {}
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "terraform_group" {
    name     = "terraformresourcegroup"
    location = "eastus"
}

# Create virtual network
resource "azurerm_virtual_network" "terraform_network" {
    name                = "terraformVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.terraform_group.name
}

# Create subnet
resource "azurerm_subnet" "terraform_subnet" {
    name                 = "terraformSubnet"
    resource_group_name  = azurerm_resource_group.terraform_group.name
    virtual_network_name = azurerm_virtual_network.terraform_network.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "terraform_publicip" {
    name                         = "terraformPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.terraform_group.name
    allocation_method            = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraform_nsg" {
    name                = "terraformNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.terraform_group.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Create network interface
resource "azurerm_network_interface" "terraform_nic" {
    name                      = "terraformNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.terraform_group.name
    #network_security_group_id = azurerm_network_security_group.terraform_nsg.id

    ip_configuration {
        name                          = "terraformNicConfiguration"
        subnet_id                     = azurerm_subnet.terraform_subnet.id
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = azurerm_public_ip.terraform_publicip.id
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.terraform_group.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "terraform_storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.terraform_group.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

# Create virtual machine
resource "azurerm_virtual_machine" "terraform_vm" {
    name                  = "terraformVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.terraform_group.name
    network_interface_ids = ["${azurerm_network_interface.terraform_nic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "terraformOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = var.azure_computer_name
        admin_username = var.azure_admin_username
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = var.azure_ssh_key_data
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.terraform_storageaccount.primary_blob_endpoint
    }
}