# Habilitar APIs necessárias
resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Criar repositório no Artifact Registry
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = "us-central1"
  repository_id = "meu-servico"
  format        = "DOCKER"
  depends_on = [google_project_service.artifactregistry_api]
}

# Adicionar permissão para a conta de serviço ler imagens
resource "google_artifact_registry_repository_iam_member" "repo_reader" {
  project    = var.project_id
  location   = "us-central1"
  repository = google_artifact_registry_repository.repo.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.service_account_email}"
}

# Recurso do Cloud Run
resource "google_cloud_run_service" "default" {
  name     = "meu-servico-dev"
  location = "us-central1"
  project  = var.project_id

  template {
    spec {
      service_account_name = var.service_account_email
      containers {
        image = "gcr.io/desafio-devops-dev/meu-servico:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Garantir que o repositório e permissões estejam criados antes do serviço
  depends_on = [
    google_project_service.cloud_run_api,
    google_project_service.artifactregistry_api,
    google_artifact_registry_repository.repo,
    google_artifact_registry_repository_iam_member.repo_reader
  ]
}

# Política IAM para acesso público
resource "google_cloud_run_service_iam_member" "noauth" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_project_service" "cloudresourcemanager_api" {
  service = "cloudresourcemanager.googleapis.com"
  project = var.project_id
  disable_on_destroy = false
}