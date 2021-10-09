# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "this" {
  name     = format("rg-%s-shared", var.environment)
  location = var.location

  tags = {
    environment = var.environment
  }
}


resource "azurerm_container_registry" "acr" {
  name                = "acrsharedtest"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "storagetfstatetest"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstatecontainer"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"

}