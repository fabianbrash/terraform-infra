resource "rafay_workload" "fb-ghost" {
  metadata {
    name    = "fb-ghost"
    project = "fb-demoes"
  }
  spec {
    namespace = "fb-ghost"
    placement {
      selector = "rafay.dev/clusterName=fb-aks-v3-tf-1"
    }
    version = "v0"
    artifact {
      type = "Yaml"
      artifact {
        paths {
          name = "file://ghost-deploy.yaml"
        }
      }
    }
  }
}
