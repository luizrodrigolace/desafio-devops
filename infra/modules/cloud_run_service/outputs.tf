output "cloud_run_url" {
  description = "URL do serviço Cloud Run implantado"
  value       = google_cloud_run_service.default.status[0].url
}

output "artifact_registry_repository" {
  description = "Nome do repositório de artefatos"
  value       = google_artifact_registry_repository.repo.name
}

output "service_account_email" {
  description = "Email da service account utilizada"
  value       = var.service_account_email
}