#!/bin/bash

# Iniciar Ollama en segundo plano
echo "Starting Ollama..."
sudo -u oceanos ollama serve > /var/log/ollama.log 2>&1 &
OLLAMA_PID=$!

# Esperar a que Ollama esté listo
echo "Waiting for Ollama to be ready..."
until curl -s http://localhost:11434/api/tags > /dev/null 2>&1; do
    sleep 2
done
echo "Ollama is ready!"

# Verificar si hay modelos instalados
MODEL_COUNT=$(curl -s http://localhost:11434/api/tags | grep -c '"name"')
if [ "$MODEL_COUNT" -eq 0 ]; then
    echo "No models found. Pulling deepseek-r1:1.5b..."
    sudo -u oceanos ollama pull deepseek-r1:1.5b
    echo "Model downloaded successfully!"
else
    echo "Models already installed. Skipping download."
fi

# Iniciar n8n en segundo plano
echo "Starting n8n..."
sudo -u oceanos n8n > /var/log/n8n.log 2>&1 &
N8N_PID=$!

echo "All services started!"
echo "Ollama PID: $OLLAMA_PID"
echo "n8n PID: $N8N_PID"
echo ""
echo "Services available at:"
echo "  - n8n: http://localhost:5678"
echo "  - Ollama: http://localhost:11434"

# Mantener el contenedor vivo
tail -f /dev/null
