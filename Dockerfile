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
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

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

# Copy start script
COPY start.sh .
RUN chmod +x start.sh

# Expose ports
EXPOSE 8000 3000

# Start the application
CMD ["./start.sh"]
