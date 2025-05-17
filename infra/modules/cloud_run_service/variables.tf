variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "service_name" {
  description = "Nome do serviço Cloud Run"
  type        = string
}

variable "region" {
  description = "Região GCP para implantação"
  type        = string
  default     = "us-central1"
}

variable "image" {
  description = "Caminho completo da imagem Docker"
  type        = string
}

variable "service_account_email" {
  description = "Email da service account"
  type        = string
}

variable "cpu_limit" {
  description = "Limite de CPU por container"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Limite de memória por container"
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Número mínimo de instâncias"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Número máximo de instâncias"
  type        = number
  default     = 3
}

variable "allow_public_access" {
  description = "Habilita acesso público ao serviço"
  type        = bool
  default     = false
}