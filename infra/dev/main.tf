module "network" {
  source = "../modules/network"

  environment           = "dev"
  region                = "southamerica-east1"  # Região diferente para dev
  cloud_run_service_name = module.cloud_run_dev.service_name
  allowed_ips           = var.allowed_ips
}

variable "allowed_ips" {
  type    = list(string)
  default = [
    "177.220.180.15/32",   # IP do escritório
    "45.179.105.0/24",     # Faixa de desenvolvimento
    "${data.http.current_ip.body}/32"
  ]
}

data "http" "current_ip" {
  url = "https://ifconfig.me/ip"
}