# Usa imagem oficial do Python
FROM python:3.10-slim

# Define diretório de trabalho
WORKDIR /app

# Copia arquivos necessários
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante da aplicação
COPY . .

# Garante que o script de inicialização tenha permissão de execução
RUN chmod +x start.sh

# Expõe a porta que o Gunicorn usará
EXPOSE 8000

# Comando para iniciar a aplicação
CMD ["./start.sh"]
