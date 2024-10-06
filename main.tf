terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "4fa64e38-8720-43bf-8eb9-7220fa853fea"
}

resource "azurerm_resource_group" "rg" {
  name = "Cours_info_en_nuage"
  location = "France Central"
}

resource "azurerm_storage_account" "storage" {
  name = "storagedevfunc"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name = "asp-azure-function"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name = "func-azure-python"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  storage_account_name = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version = "~4"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "python"
    PYTHON_VERSION = "3.9"
  }
}

resource "azurerm_postgresql_server" "postgres" {
  name = "postgresqlserverfunc"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name   = "B_Gen5_1"
  storage_mb = 5120
  version    = "11"

  administrator_login = "adminuser"
  administrator_login_password = "@dm1n"

  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled = true
  ssl_enforcement_enabled = false
}

resource "azurerm_postgresql_database" "postgres_db" {
  name = "funcdb"
  resource_group_name = azurerm_resource_group.rg.name
  server_name = azurerm_postgresql_server.postgres.name
  charset = "UTF8"
  collation = "ucs_basic"
}

