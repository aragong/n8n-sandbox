# Utilizando la última LTS de 2026
FROM ubuntu:24.04

# Configuración de entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:$PATH"

# 1. Instalar dependencias base, Node.js 20+ y Python
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    build-essential \
    git \
    python3-full \
    python3-pip \
    && curl -fsSL deb.nodesource.com | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 2. Instalar uv (gestor de paquetes) y ruff (linter/formatter)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv tool install ruff

# 3. Instalar n8n y Ollama
RUN npm install n8n -g
RUN curl -fsSL ollama.com | sh

# 4. Definir directorios de trabajo y volúmenes
WORKDIR /data
VOLUME ["/root/.n8n", "/root/.ollama"]

# 5. Script de inicio: Levanta Ollama, descarga DeepSeek y lanza n8n
RUN echo '#!/bin/bash\n\
ollama serve &\n\
echo "Esperando a que el servicio Ollama esté disponible..."\n\
until curl -s http://localhost:11434/api/tags > /dev/null; do sleep 2; done\n\
echo "Comprobando modelo DeepSeek-R1:8b..."\n\
ollama pull deepseek-r1:8b\n\
echo "Iniciando n8n..."\n\
n8n start' > /start.sh && chmod +x /start.sh

# Puertos para n8n y Ollama
EXPOSE 5678 11434

CMD ["/start.sh"]
