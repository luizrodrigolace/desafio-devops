variable "environment" {
  description = "Nome do ambiente (dev/prod)"
  type        = string
}

variable "region" {
  description = "Região GCP"
  type        = string
}

variable "cloud_run_service_name" {
  description = "Nome do serviço Cloud Run"
  type        = string
}

variable "allowed_ips" {
  description = "Lista de IPs autorizados"
  type        = list(string)
}