FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    curl \
    && echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list.d/kali.list \
    && curl -fsSL https://archive.kali.org/archive-key.asc | apt-key add - \
    && apt-get update && apt-get install -y \
    nmap \
    nikto \
    hydra \
    sqlmap \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@10.2.4

# Set working directory
WORKDIR /app

# Copy backend files
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

# Copy frontend files
COPY frontend/ /app/frontend/

# Install frontend dependencies and build
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Return to app directory
WORKDIR /app

# Create start script
RUN echo '#!/bin/bash\n\
\n\
# Wait for database to be ready\n\
echo "Waiting for database to be ready..."\n\
while ! nc -z db 5432; do\n\
  sleep 1\n\
done\n\
echo "Database is ready!"\n\
\n\
# Start FastAPI backend\n\
echo "Starting FastAPI backend..."\n\
cd /app\n\
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &\n\
\n\
# Start React frontend\n\
echo "Starting React frontend..."\n\
cd /app/frontend\n\
npm start &\n\
\n\
# Keep container running\n\
wait' > /app/start.sh && chmod +x /app/start.sh

# Expose ports
EXPOSE 8000 3000

# Start the application
CMD ["/app/start.sh"]
