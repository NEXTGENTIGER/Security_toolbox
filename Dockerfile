FROM python:3.9-slim

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    nmap \
    tshark \
    nodejs \
    npm \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Création du répertoire de l'application
WORKDIR /app

# Installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Installation des dépendances Node.js
COPY frontend/package*.json ./frontend/
WORKDIR /app/frontend
RUN npm install

# Copie du code source
WORKDIR /app
COPY . .

# Construction du frontend
WORKDIR /app/frontend
RUN npm run build

# Retour au répertoire principal
WORKDIR /app

# Exposition des ports
EXPOSE 8000 3000

# Script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"] 