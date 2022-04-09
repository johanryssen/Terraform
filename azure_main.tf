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
  name     = "RG_1005"
  location = "Southeast Asia"
}

# Create virtual network
resource "azurerm_virtual_network" "TerraFormNetwork_1005" {
    name                = "virt_net_name_1005"               ## Virtual network name
    address_space       = ["10.10.0.0/16"]
    location            = "Southeast Asia"
    resource_group_name = "RG_1005"

    tags = {
        environment = "Terraform VNET tag"
    }
}
# Create subnet
resource "azurerm_subnet" "terraform_subnet_1005" {
    name                 = "subnet_name_1005"
    resource_group_name = "RG_1005"
    virtual_network_name = azurerm_virtual_network.TerraFormNetwork_1005.name
    address_prefixes     = ["10.10.2.0/24"]
}

# Deploy Public IP
resource "azurerm_public_ip" "pub_ip_resource_1005" {
  name                = "public_ip_1005"
  location            = "Southeast Asia"
  resource_group_name = "RG_1005"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

# Create NIC
resource "azurerm_network_interface" "nic_resource_1005" {
  name                = "nic_name_1005"
  location            = "Southeast Asia"
  resource_group_name = "RG_1005"

    ip_configuration {
    name                          = "ipconfig001"
    subnet_id                     = azurerm_subnet.terraform_subnet_1005.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip_resource_1005.id
  }
}

# Create Boot Diagnostic Account
resource "azurerm_storage_account" "fileshare_1005" {      # File share
  name                     = "storeacc58295"                # Storage Account - no_UNDESCORE
  resource_group_name      = "RG_1005"
  location                 = "Southeast Asia"
   account_tier            = "Standard"
   account_replication_type = "LRS"

   tags = {
    environment = "Boot Diagnostic Storage"
    CreatedBy = "Admin"
   }
  }

# Create Virtual Machine
resource "azurerm_virtual_machine" "vm_resource_1005" {
  name                  = "virt_machine_1005"
  location              = "Southeast Asia"
  resource_group_name   = "RG_1005"
  network_interface_ids = [azurerm_network_interface.nic_resource_1005.id]
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
    name              = "osdisk_1005"
    disk_size_gb      = "65"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "computername_1005"
    admin_username = "myadminaccount"
    admin_password = "MyP@ssword!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.fileshare_1005.primary_blob_endpoint
    }
}