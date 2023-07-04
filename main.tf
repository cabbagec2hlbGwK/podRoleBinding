provider "aws" {
  region = var.region
}
module "cluster" {
  source = "./k8sCluster"
}

resource "aws_s3_bucket" "test" {
  bucket = "test121212812"
}


provider "kubernetes" {
  host                   = module.cluster.K8sHost
  cluster_ca_certificate = module.cluster.K8sCa
  token                  = module.cluster.K8sToken
}
resource "kubernetes_pod" "test" {
  metadata {
    name = "terraform-example"
  }

  spec {
    service_account_name = "aws-account"
    container {
      image = "cabbageshell/s3_check"
      name  = "example"

      env {
        name  = "BUCKET"
        value = aws_s3_bucket.test.bucket
      }
    }
  }
}

output "thumbprint" {
  value = module.cluster.thumb
}
