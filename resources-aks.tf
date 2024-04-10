resource "azurerm_resource_group" "aks_rg" {
  name     = "myaksResourceGroup"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "myaksdns"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count       = 1
    max_count       = 2
    // Additional optional settings can be specified here.
  }

  identity {
    type = "SystemAssigned"
  }

  // Ensure you replace these with actual values if not using a system-assigned identity
  // service_principal {
  //   client_id     = "<your-service-principal-client-id>"
  //   client_secret = "<your-service-principal-client-secret>"
  // }

  tags = {
    Owner = "me"
    Department = "IT"
    email = "me@gmail.com"
  }
}

