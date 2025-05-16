#!/bin/bash
if [ "$LOCAL" == "true" ]; then
  echo "Iniciando em modo de desenvolvimento (debug)"
  flask --app app.py run --debug --host=0.0.0.0 --port=8000
else
  echo "Iniciando com Gunicorn (produção)"
  gunicorn -w 4 -b 0.0.0.0:8000 app:app
fi