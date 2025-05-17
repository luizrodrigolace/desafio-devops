# Habilitar APIs necessárias
resource "google_project_service" "cloud_run_api" {
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry_api" {
  project            = var.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager_api" {
  service            = "cloudresourcemanager.googleapis.com"
  project            = var.project_id
  disable_on_destroy = false
}

# Criar repositório no Artifact Registry
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = "meu-servico"
  format        = "DOCKER"
  depends_on    = [google_project_service.artifactregistry_api]

  lifecycle {
    ignore_changes = [
      labels,          # Ignora mudanças em labels
      create_time,     # Ignora o timestamp de criação
      update_time      # Ignora o timestamp de atualização
    ]
  }
}

# Permissões do Artifact Registry
resource "google_artifact_registry_repository_iam_member" "repo_reader" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.repo.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${var.service_account_email}"
}

# Permissões do Cloud Run
resource "google_project_iam_member" "run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${var.service_account_email}"
}

resource "google_project_iam_member" "sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${var.service_account_email}"
}

# Recurso principal do Cloud Run
resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    spec {
      service_account_name = var.service_account_email
      containers {
        image = var.image
        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }
        ports {
          container_port = 8080 # Garanta que está igual ao do Dockerfile
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = var.min_instances
        "autoscaling.knative.dev/maxScale" = var.max_instances
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_run_api,
    google_artifact_registry_repository.repo
  ]
}

# Acesso público (IMPORTANTE: Só usar em ambiente de produção se necessário)
resource "google_cloud_run_service_iam_member" "public_access" {
  count = var.allow_public_access ? 1 : 0

  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Acesso autenticado para usuários específicos
resource "google_cloud_run_service_iam_member" "authenticated_access" {
  count = var.allow_public_access ? 0 : 1

  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  role     = "roles/run.invoker"
  member   = "user:luizrodrigolace@gmail.com" # Substitua pelo e-mail desejado
}