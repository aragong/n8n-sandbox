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

# Función para verificar e instalar un modelo
check_and_install_model() {
    local model=$1
    echo "Checking model: $model"
    
    if curl -s http://localhost:11434/api/tags | grep -q "\"name\":\"$model\""; then
        echo "  ✓ Model $model is already installed"
        return 0
    else
        echo "  ✗ Model $model not found. Downloading..."
        sudo -u oceanos ollama pull "$model"
        if [ $? -eq 0 ]; then
            echo "  ✓ Model $model downloaded successfully!"
        else
            echo "  ✗ Failed to download model $model"
            return 1
        fi
    fi
}

# Verificar e instalar modelos por defecto
echo ""
echo "=== Checking default models ==="
check_and_install_model "qwen2.5:3b"
check_and_install_model "deepseek-r1:1.5b"
echo "=== Model check completed ==="
echo ""

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
