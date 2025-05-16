# Usa imagem oficial do Python
FROM python:3.10-slim

# Define diretório de trabalho
WORKDIR /app

# Copia a aplicação
ADD . .

# Instala os requisitos e adiciona permissão de execução ao entrypoint
RUN pip install --no-cache-dir -r requirements.txt && chmod +x start.sh

# Sinaliza que vai expor a porta que o Gunicorn usará
EXPOSE 8000

# Comando para iniciar a aplicação
ENTRYPOINT ["/app/start.sh"]