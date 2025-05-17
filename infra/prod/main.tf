module "network" {
  source = "../modules/network"

  environment           = "prod"
  region                = "us-central1"
  cloud_run_service_name = module.cloud_run_prod.service_name
  allowed_ips           = var.allowed_ips
}

variable "allowed_ips" {
  type    = list(string)
  default = [
    "200.150.100.50/32",   # IP corporativo
    "189.45.210.0/24",     # Faixa permitida
    "${data.http.current_ip.body}/32" # IP atual
  ]
}

data "http" "current_ip" {
  url = "https://ifconfig.me/ip"
}