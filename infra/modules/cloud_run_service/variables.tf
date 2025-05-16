variable "service_name" {
  description = "Nome do serviço Cloud Run"
  type        = string
}

variable "region" {
  description = "Região onde o serviço será implantado"
  type        = string
}

variable "image" {
  description = "URL da imagem do contêiner"
  type        = string
}

variable "service_account_email" {
  description = "E-mail da conta de serviço usada pelo Terraform"
  type        = string
}

variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}