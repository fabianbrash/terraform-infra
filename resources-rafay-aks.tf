resource "rafay_aks_cluster_v3" "fb-demo-terraform" {
  metadata {
    name    = "fb-aks-v3-tf-1"
    project = "fb-demoes"
  }

  spec {
    type          = "aks"
    blueprint_config {
      name = "default-aks"
      version = "1.25.0"
    }
    cloud_credentials = "fb-az-creds-exp9172024"

    config {
      kind       = "aksClusterConfig"
      metadata {
        name = "fb-aks-v3-tf-1"
      }

      spec {
        resource_group_name = "eus-rafay-aks-rg"
        managed_cluster {
          api_version = "2022-07-01"
          sku {
            name = "Basic"
            tier = "Free"
          }
          identity {
            type = "SystemAssigned"
          }
          location = "eastus"
          tags = {
            "email" = "fabian@rafay.co"
            "env" = "dev"
          }
          properties {
            api_server_access_profile {
              enable_private_cluster = true
            }
            dns_prefix         = "aks-v3-tf-2401202303-dns"
            kubernetes_version = "1.28.5"
            network_profile {
              network_plugin = "kubenet"
              load_balancer_sku = "standard"
            }
          }
          type = "Microsoft.ContainerService/managedClusters"
        }
        node_pools {
          api_version = "2022-07-01"
          name       = "primary"
          location = "eastus"
          properties {
            count                = 1
            enable_auto_scaling  = true
            max_count            = 2
            max_pods             = 40
            min_count            = 1
            mode                 = "System"
            orchestrator_version = "1.28.5"
            os_type              = "Linux"
            type                 = "VirtualMachineScaleSets"
            vm_size              = "Standard_DS2_v2"
            node_labels = {
              app = "infra"
              dedicated = "true"
            }
          }
          type = "Microsoft.ContainerService/managedClusters/agentPools"
        }

      }
    }
  }
}
