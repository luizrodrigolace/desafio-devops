# Documentação do Projeto Desafio DevOps

Este documento detalha o desenvolvimento, configuração e implantação do projeto **Desafio DevOps**, uma aplicação Flask que retorna "Hello World!" na rota `/`, containerizada com Docker e deployada no Google Cloud Run. O projeto utiliza práticas modernas de DevOps, incluindo automação com Terraform e CI/CD com GitHub Actions, superando desafios como erros no Cloud Run, problemas de WSL e configuração de workflows.

## Visão Geral

O objetivo foi criar uma aplicação web escalável, empacotá-la em um container Docker e implantá-la em ambientes de desenvolvimento (`desafio-devops-dev`) e produção (`desafio-devops-prod`) no Google Cloud Run.

Repositório GitHub: [luizrodrigolace/desafio-devops](https://github.com/luizrodrigolace/desafio-devops)

### Estrutura do Projeto

* **Aplicação**: `app.py`, `requirements.txt`, `start.sh`, `wsgi.py`
* **Containerização**: `Dockerfile`, `docker-compose.dev.yml`, `docker-compose.prod.yml`
* **Infraestrutura**: `infra/dev/`, `infra/prod/`
* **CI/CD**: `.github/workflows/` (`deploy-dev.yml`, `deploy-prod.yml`)
* **Segurança**: `bandit_report.json`

### Desafios Enfrentados

* `exec /app/start.sh: no such file or directory` no Cloud Run
* Limite de instâncias no Cloud Run (`max_instances = 5`)
* Problemas de final de linha (EOL) no WSL, corrigidos com `dos2unix`
* Autenticação da GCP nos workflows do GitHub Actions

## Configuração do Repositório

### Clonando o Repositório

```bash
git clone https://github.com/luizrodrigolace/desafio-devops
cd desafio-devops
```

### Instalando Dependências

Instale o [Poetry](https://python-poetry.org/):

```bash
pip install poetry
```

Instale as dependências:

```bash
poetry install
```

**Notas:**

* O `poetry.lock` está incluso para consistência.
* No Windows, use o WSL para compatibilidade com Docker e Terraform.

## Executando a Aplicação

### Ambiente de Desenvolvimento Local

Instale o Docker e Docker Compose:

```bash
sudo apt update
sudo apt install docker.io docker-compose
```

Inicie a aplicação em modo de desenvolvimento:

```bash
docker-compose -f docker-compose.dev.yml up --build
```

Acesse em: [http://localhost:8080](http://localhost:8080)

### Ambiente de Produção Local

```bash
docker-compose -f docker-compose.prod.yml up --build
```

**Notas:**

* `start.sh` decide entre Flask e Gunicorn via variável `LOCAL`
* Porta 8080 é exigida pelo Cloud Run

## Desenvolvimento da Aplicação

### Estrutura

* `app.py`: API Flask
* `requirements.txt`: Dependências do projeto
* `start.sh`: Script de inicialização

### Exemplo de Código (`app.py`)

```python
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello World!"

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 8080))
    app.run(host='0.0.0.0', port=port)
```

## Containerização

### Dockerfile

```Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY app.py requirements.txt start.sh ./
RUN pip install --no-cache-dir -r requirements.txt && chmod +x start.sh
EXPOSE 8080
ENTRYPOINT ["/app/start.sh"]
```

### start.sh

```bash
#!/bin/bash
PORT=${PORT:-8080}
if [ "$LOCAL" == "true" ]; then
  echo "Iniciando em modo de desenvolvimento (debug)"
  flask --app app.py run --debug --host=0.0.0.0 --port=$PORT
else
  echo "Iniciando com Gunicorn (produção)"
  ls -l /app # Debug
  python --version
  pip list
  gunicorn -w 3 -b 0.0.0.0:$PORT app:app --log-level debug
fi
```

### .dockerignore (exemplo)

```
venv/
**/__pycache__/
*.pyc
*.log
.git/
.dockerignore
docker-compose.*.yml
bandit_report.json
*.swp
.DS_Store
infra/
```

## Infraestrutura com Terraform

### Exemplo: `infra/modules/cloud_run_service/main.tf`

```hcl
resource "google_cloud_run_service" "default" {
  name     = "meu-servico-${var.environment}"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/desafio-devops-${var.environment}/meu-servico:latest"
        env {
          name  = "LOCAL"
          value = "false"
        }
        env {
          name  = "PORT"
          value = "8080"
        }
      }
      timeout_seconds = 300
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "5"
      }
    }
  }
}
```

### Aplicando

```bash
cd infra/dev
terraform apply -auto-approve
cd ../prod
terraform apply -auto-approve -var="environment=prod"
```

**Notas:**

* `tf-state-prod-bucket` armazena o estado para produção
* Erro comum: `Revision 'meu-servico-prod-00001-fhs' is not ready`

## Fluxo de Desenvolvimento

### Estrutura de Branches

* `main`: Produção
* `develop`: Desenvolvimento
* `feature/*`: Novas funcionalidades

### Criando uma Nova Funcionalidade

```bash
git checkout develop
git checkout -b feature/nome-da-funcionalidade
```

Commits devem seguir o padrão:

```
feat: adiciona endpoint hello world
```

Crie PR para `develop`. Após testes, merge para `main`.

## CI/CD com GitHub Actions

### `deploy-dev.yml`

```yaml
name: Deploy Dev
on:
  push:
    branches:
      - develop

jobs:
  deploy:
    name: Deploy to GCP - Dev
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6

      - name: Authenticate with GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS_DEV }}

      - name: Set GCP Project and Region
        run: |
          echo "GOOGLE_CLOUD_PROJECT=desafio-devops-dev" >> $GITHUB_ENV
          echo "GOOGLE_CLOUD_REGION=southamerica-east1" >> $GITHUB_ENV

      - name: Terraform Init
        run: terraform init
        working-directory: ./infra/dev

      - name: Terraform Plan
        run: terraform plan
        working-directory: ./infra/dev

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./infra/dev
```

### `deploy-prod.yml`

```yaml
name: Deploy Prod
on:
  push:
    branches:
      - main
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    name: Deploy to GCP - Prod
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.6
          terraform_wrapper: false

      - name: Authenticate with GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS_PROD }}
          workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/github
          service_account: terraform-prod@desafio-devops-prod.iam.gserviceaccount.com

      - name: Set GCP Project and Region
        run: |
          echo "GOOGLE_CLOUD_PROJECT=desafio-devops-prod" >> $GITHUB_ENV
          echo "GOOGLE_CLOUD_REGION=us-central1" >> $GITHUB_ENV

      - name: Terraform Init
        run: terraform init -backend-config="bucket=tf-state-prod-bucket"
        working-directory: ./infra/prod

      - name: Terraform Validate
        run: terraform validate
        working-directory: ./infra/prod

      - name: Terraform Plan
        run: terraform plan
        working-directory: ./infra/prod

      - name: Terraform Apply
        run: terraform apply -auto-approve
        working-directory: ./infra/prod
```

---

