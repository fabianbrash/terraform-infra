resource "azurerm_resource_group" "example" {
  name     = "fb-example-resources-rg"
  location = "East US"
}

resource "azurerm_app_service_plan" "example" {
  name                = "fb-example-appservice-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "fb-example-terra252-appservice"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}

resource "azurerm_storage_account" "example_sa" {
  name                     = "fbcustomrolesa${random_string.example_sa_suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "example_container" {
  name                  = "example-container"
  storage_account_name  = azurerm_storage_account.example_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "example_file_share" {
  name                 = "examplefileshare"
  storage_account_name = azurerm_storage_account.example_sa.name
  quota                = 50
}

resource "random_string" "example_sa_suffix" {
  length  = 8
  special = false
  upper   = false
}


resource "azurerm_resource_group" "exampleappgw" {
  name     = "fb-example-appgw-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "exampleVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.exampleappgw.location
  resource_group_name = azurerm_resource_group.exampleappgw.name
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "exampleAppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.exampleappgw.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example_public_ip" {
  name                = "examplePublicIP"
  location            = azurerm_resource_group.exampleappgw.location
  resource_group_name = azurerm_resource_group.exampleappgw.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "example_agw" {
  name                = "exampleApplicationGateway"
  location            = azurerm_resource_group.exampleappgw.location
  resource_group_name = azurerm_resource_group.exampleappgw.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "exampleGatewayIpConfig"
    subnet_id = azurerm_subnet.example_subnet.id
  }

  frontend_port {
    name = "exampleFrontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "exampleFrontEndIpConfig"
    public_ip_address_id = azurerm_public_ip.example_public_ip.id
  }

  backend_address_pool {
    name = "exampleBackendAddressPool"
  }

  backend_http_settings {
    name                  = "exampleBackendHttpSettings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "exampleHttpListener"
    frontend_ip_configuration_name = "exampleFrontEndIpConfig"
    frontend_port_name             = "exampleFrontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "exampleRequestRoutingRule"
    rule_type                  = "Basic"
    http_listener_name         = "exampleHttpListener"
    backend_address_pool_name  = "exampleBackendAddressPool"
    backend_http_settings_name = "exampleBackendHttpSettings"
    priority                   = 100
  }
}

