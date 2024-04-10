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

resource "rafay_eks_cluster" "fb-eks-terraform" {
  cluster {
    kind = "Cluster"
    metadata {
      name    = "fb-eks-terraform"
      project = "fb-demoes"
    }
    spec {
      type              = "eks"
      blueprint         = "minimal"
      cloud_provider    = "fb-aws-creds"
      cni_provider      = "aws-cni"
      proxy_config      = {}
    }
  }
  cluster_config {
    apiversion = "rafay.io/v1alpha5"
    kind       = "ClusterConfig"
    metadata {
      name    = "fb-eks-terraform"
      region  = "us-east-2"
      version = "1.26"
    }
    vpc {
      cidr = "192.168.0.0/16"
      cluster_endpoints {
        private_access = true
        public_access  = false
      }
    }
    iam {
     with_oidc = true
    }

    vpc {
      cluster_endpoints {
        private_access = true
        public_access  = false
      }
    }
    managed_nodegroups {
      name = "ng1"
      instance_type      = "t3.medium"
      desired_capacity   = 2
      min_size           = 1
      max_size           = 3
      volume_size        = 80
      volume_type        = "gp3"
      version            = "1.26"
    }

    addons {
      name = "vpc-cni"
      version = "latest"
    }
    addons {
      name = "kube-proxy"
      version = "latest"
    }
    addons {
      name = "coredns"
      version = "latest"
    }
  }
}
