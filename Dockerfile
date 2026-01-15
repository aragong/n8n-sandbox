# Stage 1: Base - Dependencias del sistema
FROM ubuntu:24.04 AS base

LABEL maintainer="aragong <https://github.com/aragong>"
LABEL description="n8n sandbox with Ollama for AI agent development"
LABEL version="1.0"

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    openssh-client \
    ca-certificates \
    sudo \
    zstd \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Node - Instalación de Node.js
FROM base AS node

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Stage 3: User - Crear usuario oceanos
FROM node AS user

RUN if id -u ubuntu > /dev/null 2>&1; then userdel -r ubuntu; fi && \
    useradd -m -s /bin/bash -u 1000 oceanos && \
    echo "oceanos ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Stage 4: N8N - Instalar n8n
FROM user AS n8n

RUN npm install -g n8n

# Stage 5: Python Tools - Instalar uv y ruff
FROM n8n AS python-tools

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv tool install ruff

# Stage 6: Ollama - Instalar Ollama
FROM python-tools AS ollama

RUN curl -fsSL https://ollama.com/install.sh | sh

# Stage 7: Final - Configuración final
FROM ollama AS final

RUN mkdir -p /home/oceanos/.n8n /home/oceanos/.ollama && \
    chown -R oceanos:oceanos /home/oceanos

USER oceanos
WORKDIR /home/oceanos

USER root
COPY start-services.sh /start-services.sh
RUN chmod +x /start-services.sh && mkdir -p /var/log && chmod 777 /var/log

# Services will be available at:
# - n8n: http://localhost:5678
# - Ollama API: http://localhost:11434
EXPOSE 5678 11434

USER oceanos
ENTRYPOINT ["/bin/bash", "/start-services.sh"]
