# Usa imagem oficial do Python
FROM python:3.10-slim

# Define diretório de trabalho
WORKDIR /app

# Copia a aplicação
ADD . .

# Instala os requisitos e adiciona permissão de execução ao entrypoint
RUN pip install --no-cache-dir -r requirements.txt && chmod +x start.sh

# Exponha a porta 8000 que seu app vai usar
EXPOSE 8080

# Comando para iniciar a aplicação via start.sh
ENTRYPOINT ["/app/start.sh"]
