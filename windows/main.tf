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

resource azurerm_resource_group terraform_resource_group {
  name     = "terraformresourcegroup"
  location = "East US"
}

resource azurerm_storage_account terraform_storageaccount {
  name                     = "vvterraformwinstg"
  resource_group_name      = azurerm_resource_group.terraform_resource_group.name
  location                 = azurerm_resource_group.terraform_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create Public IP
resource azurerm_public_ip terraform_publicip {
  name                = "terraformPublicIP"
  location            = azurerm_resource_group.terraform_resource_group.location
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
  allocation_method   = "Dynamic"
}

# Create a virtual network within the resource group
resource azurerm_virtual_network terraform_network {
  name                = "terraformVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraform_resource_group.location
  resource_group_name = azurerm_resource_group.terraform_resource_group.name
}

#create subnets
resource azurerm_subnet terraform_subnet1 {
  name                 = "terraformSubnet1"
  resource_group_name  = azurerm_resource_group.terraform_resource_group.name
  virtual_network_name = azurerm_virtual_network.terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource azurerm_subnet terraform_subnet2 {
  name                 = "terraformSubnet2"
  resource_group_name  = azurerm_resource_group.terraform_resource_group.name
  virtual_network_name = azurerm_virtual_network.terraform_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource azurerm_subnet terraform_subnet3 {
  name                 = "terraformSubnet3"
  resource_group_name  = azurerm_resource_group.terraform_resource_group.name
  virtual_network_name = azurerm_virtual_network.terraform_network.name
  address_prefixes     = ["10.0.3.0/24"]
}

#Create network interface
resource azurerm_network_interface terraform_nic {
  name                = "terraformNIC"
  location            = azurerm_resource_group.terraform_resource_group.location
  resource_group_name = azurerm_resource_group.terraform_resource_group.name

  ip_configuration {
    name                          = "Server2016"
    subnet_id                     = azurerm_subnet.terraform_subnet1.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform_publicip.id
  }
}

resource azurerm_managed_disk terraform_managed_disk {
  name                 = "terraformManagedDisk"
  location             = azurerm_resource_group.terraform_resource_group.location
  resource_group_name  = azurerm_resource_group.terraform_resource_group.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource azurerm_virtual_machine terraform_vm {
  name                             = "terraformVM"
  location                         = azurerm_resource_group.terraform_resource_group.location
  resource_group_name              = azurerm_resource_group.terraform_resource_group.name
  network_interface_ids            = ["${azurerm_network_interface.terraform_nic.id}"]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"

  storage_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  storage_os_disk {
    name              = "datadisk_new_2018_01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Adding additional disk 1
  storage_data_disk {
    name              = "datadisk_new"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "1023"
  }

  #Additional disk 2
  storage_data_disk {
    name            = azurerm_managed_disk.terraform_managed_disk.name
    managed_disk_id = azurerm_managed_disk.terraform_managed_disk.id
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = azurerm_managed_disk.terraform_managed_disk.disk_size_gb
  }

  #define credentials
  os_profile {
    computer_name  = "SERVER2016"
    admin_username = var.azure_vm_username
    admin_password = var.azure_vm_password
  }

  os_profile_windows_config {
    provision_vm_agent        = "true"
    enable_automatic_upgrades = "true"
    winrm {
      protocol        = "http"
      certificate_url = ""
    }
  }
}
