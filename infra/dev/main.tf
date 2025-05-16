provider "google" {
  credentials = file("../modules/cloud_run_service/desafio-devops-dev-51cc0f412da9.json")
  project     = "desafio-devops-dev"
  region      = "us-central1"
}

module "cloud_run_service" {
  source                = "../modules/cloud_run_service"
  service_name          = "meu-servico-dev"
  image                 = "gcr.io/desafio-devops-dev/meu-servico:latest"
  region                = "us-central1"
  service_account_email = "github-actions-deployer@desafio-devops-dev.iam.gserviceaccount.com"
  project_id            = "desafio-devops-dev"
}