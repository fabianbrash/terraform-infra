resource "rafay_workload" "apache-airflow" {
  metadata {
    name    = "apache-airflow"
    project = "fb-demoes"
  }
  spec {
    namespace = "fb-airflow"
    placement {
      selector = "rafay.dev/clusterName=fb-aks-v3-tf-1"
    }
    version = "v0"
    artifact {
      type = "Helm"
      artifact{
        values_paths {
          name = "file://values.yaml"
        }

        repository = "apache-airflow"
        chart_name = "airflow"
        chart_version = "1.13.1"
      }
    }
  }
}
