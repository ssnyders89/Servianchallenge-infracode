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
  name     = format("rg-%s-challenge", var.environment)
  location = var.location

  tags = {
    environment = var.environment
  }
}


resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = {
    environment = var.environment
  }
}

/*
resource "azurerm_container_group" "challenge01" {
  name                = "techchallenge"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "public"
  dns_name_label      = "aci-label"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "microsoft/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  tags = {
    environment = var.environment
  }
}
*/

resource "azurerm_key_vault" "challenge" {
  name                        = "challenge"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = "93738cb5-9dc2-4670-81cf-31aac746d957"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = "93738cb5-9dc2-4670-81cf-31aac746d957"
    object_id = "5fca3f48-a24b-4b12-8fcd-3b0130d210c8"

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get", "Set", "Delete", "list",
    ]

    storage_permissions = [
      "Get",
    ]
  }
    tags = {
    environment = var.environment
  }
}


resource "azurerm_postgresql_server" "challenge" {
  name                = "postgresql-challenge-1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.6"
  ssl_enforcement_enabled      = true
    tags = {
    environment = var.environment
  }
}

resource "azurerm_postgresql_database" "challenge" {
  name                = "challengedb"
  resource_group_name = azurerm_resource_group.this.name
  server_name         = azurerm_postgresql_server.challenge.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}