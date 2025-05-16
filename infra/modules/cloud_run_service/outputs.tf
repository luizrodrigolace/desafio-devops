output "service_url" {
  description = "URL do serviço no Cloud Run"
  value       = google_cloud_run_service.default.status[0].url
}
