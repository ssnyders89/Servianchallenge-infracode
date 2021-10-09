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

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-test-shared"
    storage_account_name = "storagetfstatetest"
    container_name       = "tfstatecontainer"
    key                  = "prod.terraform.tfstate"
  }
}

resource "azurerm_resource_group" "this" {
  name     = format("rg-%s-challenge", var.environment)
  location = var.location

  tags = {
    environment = var.environment
  }
}


resource "azurerm_container_group" "challenge01" {
  name                = "techchallenge01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  ip_address_type     = "public"
  dns_name_label      = "servian-challenge01"
  os_type             = "Linux"
  restart_policy      = "Always"
  image_registry_credential {
    username = "acrsharedtest"
    password = data.azurerm_key_vault_secret.acrsecret.value
    server = "acrsharedtest.azurecr.io"
  }
  container {
    name   = "challenge01"
    image  = "acrsharedtest.azurecr.io/techchallengeapp12:14"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }
  }

  tags = {
    environment = var.environment
  }
}


resource "azurerm_key_vault" "challenge" {
  name                        = "challenge-pwd01"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = "93738cb5-9dc2-4670-81cf-31aac746d957"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = "93738cb5-9dc2-4670-81cf-31aac746d957"
    object_id = "41876c24-e57b-4772-b3f3-bcf21912fa81"

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

}

  resource "azurerm_key_vault_secret" "challenge1" {
  name         = "postgressqlsecret"
  value        = random_string.postgressqlsecret.result
  key_vault_id = azurerm_key_vault.challenge.id

    tags = {
    environment = var.environment
  }
}

  resource "azurerm_key_vault_secret" "acrsecret" {
  name         = "acrsecret"
  value        = data.azurerm_container_registry.acrsecret.admin_password
  key_vault_id = azurerm_key_vault.challenge.id

    tags = {
    environment = var.environment
  }
}
resource "random_string" "postgressqlsecret" {
  length           = 16
  special          = false
  override_special = "/@£$"
}

resource "azurerm_postgresql_server" "challenge" {
  name                = "postgresql-challenge-01"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladminun"
  administrator_login_password = "OBBzSsbTSnznYMH6"
  version                      = "9.6"
  ssl_enforcement_enabled      = false
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

data "azurerm_key_vault_secret" "challenge" {
  name         = "postgressqlsecret"
  key_vault_id = azurerm_key_vault.challenge.id
}

data "azurerm_key_vault_secret" "acrsecret" {
  name         = "acrsecret"
  key_vault_id = azurerm_key_vault.challenge.id
}

data "azurerm_container_registry" "acrsecret" {
  name         = "acrsharedtest"
  resource_group_name = "rg-test-shared"
}