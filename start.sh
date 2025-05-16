#!/bin/bash

PORT=${PORT:-8080}  # usa 8080 como padrão, se PORT não estiver setada

if [ "$LOCAL" == "true" ]; then
  echo "Iniciando em modo de desenvolvimento (debug)"
  flask --app app.py run --debug --host=0.0.0.0 --port=$PORT
else
  echo "Iniciando com Gunicorn (produção)"
  gunicorn -w 4 -b 0.0.0.0:$PORT app:app
fi
