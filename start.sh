#!/bin/bash

# Attendre que la base de données soit prête
echo "Waiting for database to be ready..."
while ! nc -z db 5432; do
  sleep 0.1
done
echo "Database is ready!"

# Démarrer le backend FastAPI
cd /app
echo "Starting FastAPI backend..."
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &

# Démarrer le frontend React
cd /app/frontend
echo "Starting React frontend..."
npm start &

# Garder le conteneur en vie
tail -f /dev/null 