# Configure the Azure provider
terraform {
  required_providers {             ### Sets up a LOCAL NAME for the provider
    azurerm = {                    ### The 'providers' block below should use this LOCAL NAME
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {              ### Should match 'required_providers' LOCAL NAME above
  features {}                     ### Empty 'features' argument
}

resource "azurerm_resource_group" "resgroup" {
  name     = "RG_67329562743"
  location = "Southeast Asia"
}

# Create virtual network
resource "azurerm_virtual_network" "TerraFormNetwork_67329562743" {
    name                = "virt_net_name_67329562743"               ## Virtual network name
    address_space       = ["10.10.10.0/24"]
    location            = "Southeast Asia"
    resource_group_name = "RG_67329562743"

    tags = {
        environment = "Terraform VNET tag"
    }
}
# Create subnet
resource "azurerm_subnet" "terraform_subnet_67329562743" {
    name                 = "subnet_name_67329562743"
    resource_group_name = "RG_67329562743"
    virtual_network_name = azurerm_virtual_network.TerraFormNetwork_67329562743.name
    address_prefix       = "10.10.10.0/24"
}

# Deploy Public IP
resource "azurerm_public_ip" "pub_ip_resource_67329562743" {
  name                = "public_ip_67329562743"
  location            = "Southeast Asia"
  resource_group_name = "RG_67329562743"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Create NIC
resource "azurerm_network_interface" "nic_resource_67329562743" {
  name                = "nic_name_67329562743"
  location            = "Southeast Asia"
  resource_group_name = "RG_67329562743"

    ip_configuration {
    name                          = "ipconfig002"
    subnet_id                     = azurerm_subnet.terraform_subnet_67329562743.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip_resource_67329562743.id
  }
}

# Create Boot Diagnostic Account
resource "azurerm_storage_account" "fileshare_67329562743" {      # File share
  name                     = "storeacc67329562743"                # Storage Account - no_UNDESCORE
  resource_group_name      = "RG_67329562743"
  location                 = "Southeast Asia"
   account_tier            = "Standard"
   account_replication_type = "LRS"

   tags = {
    environment = "Boot Diagnostic Storage"
    CreatedBy = "Admin"
   }
  }

# Create Virtual Machine
resource "azurerm_virtual_machine" "vm_resource_67329562743" {
  name                  = "virt_machine_67329562743"
  location              = "Southeast Asia"
  resource_group_name   = "RG_67329562743"
  network_interface_ids = [azurerm_network_interface.nic_resource_67329562743.id]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk1"
    disk_size_gb      = "65"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "computername67329562743"
    admin_username = "myadminaccount"
    admin_password = "PASSWORD_HERE!!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.fileshare_67329562743.primary_blob_endpoint
    }
}
```
