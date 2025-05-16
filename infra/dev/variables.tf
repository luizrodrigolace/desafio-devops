variable "service_name" {
  description = "Nome do serviço no Cloud Run"
  type        = string
}

variable "region" {
  description = "Região do serviço"
  type        = string
}

variable "image" {
  description = "Imagem do container"
  type        = string
}
