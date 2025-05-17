# Configuração específica para produção

provider "google" {
  project     = "desafio-devops-prod"
  region      = "us-central1"
  credentials = file("../modules/cloud_run_service/desafio-devops-prod-9d3deecc8f58.json")
}

module "cloud_run_prod" {
  source = "../modules/cloud_run_service"

  # Parâmetros específicos do ambiente prod
  region               = "us-central1"
  service_name          = "meu-servico-prod"
  image                 = "us-central1-docker.pkg.dev/desafio-devops-prod/meu-servico/meu-servico:latest"
  service_account_email = "terraform-prod@desafio-devops-prod.iam.gserviceaccount.com"
  project_id            = "desafio-devops-prod"
  allow_public_access   = true
  cpu_limit             = "2"
  memory_limit          = "1Gi"
  min_instances         = 1
  max_instances         = 5
}