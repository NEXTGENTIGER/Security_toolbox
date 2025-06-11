#!/bin/bash

# Démarrer le backend FastAPI
cd /app
uvicorn app.main:app --host 0.0.0.0 --port 8000 &

# Démarrer le frontend React
cd /app/frontend
npm start &

# Garder le conteneur en vie
tail -f /dev/null 