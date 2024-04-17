resource "rafay_namespace" "fb-ghost" {
  metadata {
    name    = "fb-ghost"
    project = "fb-demoes"
  }
  spec {
    drift {
      enabled = false
    }
    placement {
      labels {
        key   = "rafay.dev/clusterName"
        value = "fb-ric-mks-1"
      }
      labels {
        key   = "rafay.dev/clusterName"
        value = "onprem-iterate-clust1"
      }
    }
  }
}
resource "rafay_workload" "fb-ghost" {
  metadata {
    name    = "fb-ghost"
    project = "fb-demoes"
  }
  spec {
    namespace = "fb-ghost"
    placement {
      selector = "rafay.dev/clusterName=fb-ric-mks-1"
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
  depends_on = [ rafay_namespace.fb-ghost ]
}
