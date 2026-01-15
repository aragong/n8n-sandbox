# n8n-sandbox

A Docker-based sandbox environment for building and testing AI agents in n8n with local LLM support via Ollama.

## 🚀 Features

- **n8n Workflow Automation**: Full-featured n8n instance for creating AI workflows
- **Local LLM Support**: Integrated Ollama for running AI models locally
- **Persistent Data**: All workflow data and models are persisted between restarts
- **Easy Setup**: Automated service initialization and model download
- **Dev Container Ready**: Optimized for VS Code development

> ⚠️ **Important**: Workflow data and configurations are stored locally in `n8n_data/` and `ollama_data/`. These directories are **not** included in version control. If you delete these folders or clone the repository on a new machine, all workflows, credentials, and downloaded models will be lost. Make sure to backup important workflows manually if needed.
> 
> 💾 **Docker Persistence**: Data is safe during container rebuilds, restarts, or image updates since it's stored in bind mounts on your host machine. Data is only lost if you manually delete the folders.

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 4GB of RAM for n8n and Ollama (without models loaded)
- Additional RAM required depends on the AI model you want to run (see table below)
- Storage: ~500MB for base services + model sizes

### Recommended Ollama Models

| Model | Parameters | Size | RAM Required | Training Data | Speed | Best For |
|-------|-----------|------|--------------|---------------|-------|----------|
| **deepseek-r1:1.5b** | 1.5B | ~1GB | 2GB | 2025 | Fast | Quick tasks, testing (default) |
| **llama3.2:3b** | 3B | ~2GB | 4GB | 2024 | Fast | Lightweight tasks |
| **phi3:3.8b** | 3.8B | ~2.3GB | 4GB | 2023 | Fast | Code generation |
| **qwen2.5:7b** | 7B | ~4.7GB | 8GB | 2024 | Medium | General purpose, multilingual |
| **mistral:7b** | 7B | ~4.1GB | 8GB | 2023 | Medium | General purpose |
| **deepseek-r1:8b** | 8B | ~4.9GB | 8GB | 2025 | Medium | Balanced performance |
| **llama3.1:8b** | 8B | ~4.7GB | 8GB | 2024 | Medium | General purpose |
| **deepseek-r1:14b** | 14B | ~8.9GB | 16GB | 2025 | Slow | Advanced reasoning |
| **qwen2.5:14b** | 14B | ~9GB | 16GB | 2024 | Slow | Advanced multilingual |
| **gpt-oss:20b** | 20B | ~12GB | 24GB | 2024 | Slow | OpenAI reasoning (open-weight) |
| **qwen2.5-coder:32b** | 32B | ~19GB | 32GB | 2024 | Slow | Advanced code generation |
| **qwen2.5:32b** | 32B | ~20GB | 32GB | 2024 | Slow | Enterprise-level tasks |
| **deepseek-r1:70b** | 70B | ~40GB | 64GB | 2025 | Very Slow | State-of-the-art reasoning |
| **llama3.1:70b** | 70B | ~40GB | 64GB | 2024 | Very Slow | High-quality reasoning |
| **qwen2.5:72b** | 72B | ~43GB | 80GB | 2024 | Very Slow | Maximum performance |
| **nemotron:70b** | 70B | ~40GB | 64GB | 2024 | Very Slow | ChatGPT-level quality (NVIDIA) |
| **llama3.3:70b** | 70B | ~43GB | 80GB | 2024 | Very Slow | Latest Meta flagship |
| **gpt-oss:120b** | 120B | ~70GB | 128GB | 2024 | Very Slow | OpenAI agentic tasks (open-weight) |
| **llama3.1:405b** | 405B | ~231GB | 256GB | 2024 | Extremely Slow | Research/flagship |

> 💡 **Tip**: Start with smaller models (1.5b-3b) if you have limited RAM. For GPU clusters, models 70b+ (like **nemotron:70b**, **llama3.3:70b**, or **gpt-oss:120b**) provide ChatGPT-level performance.

## 🛠️ Services

When the container starts, the following services are automatically launched:

| Service | URL | Description |
|---------|-----|-------------|
| **n8n** | http://localhost:5678 | Workflow automation platform |
| **Ollama API** | http://localhost:11434 | Local LLM inference server |

## 🤖 Ollama Models

The container automatically checks if there are any Ollama models installed. If none are found, it will automatically download the `deepseek-r1:1.5b` model on first startup.

### Managing Models

First, access the container:
```bash
docker exec -it n8n-sandbox bash
```

Then use these commands inside the container:

**Install a model:**
```bash
ollama pull <model-name>
```

**List installed models:**
```bash
ollama list
```

**Remove a model:**
```bash
ollama rm <model-name>
```

**Run a model interactively (for testing):**
```bash
ollama run <model-name>
```

Example workflow:
```bash
# Access container
docker exec -it n8n-sandbox bash

# Install llama3.2:3b
ollama pull llama3.2:3b

# Test it
ollama run llama3.2:3b

# Exit container
exit
```

## 🎮 GPU Support (Optional)

Ollama can leverage NVIDIA GPUs to significantly accelerate inference for smaller models. This is optional and the sandbox works perfectly on CPU.

### GPU Requirements

- **NVIDIA GPU**: Compute Capability 5.0+ (GTX 700 series or newer)
- **VRAM**: 2GB minimum, 4GB+ recommended
- **Driver**: NVIDIA drivers 531+ 
- **Docker**: NVIDIA Container Toolkit (for Docker Desktop on WSL2, GPU support is built-in)

### GPU Performance

When a model fits completely in GPU VRAM, it runs at maximum speed (100% GPU). If the model is larger than available VRAM, **Ollama automatically divides the workload** between GPU and CPU for optimal performance.

**Tested Configuration:**
- **GPU**: NVIDIA GeForce GTX 750 Ti (4GB VRAM)
- **Environment**: WSL2 on Windows with Ubuntu 20.04.6 LTS
- **Driver**: NVIDIA 576.52 (WSL2) / CUDA 12.9

**Performance results with GTX 750 Ti (4GB VRAM):**
- `deepseek-r1:1.5b` (1.4GB loaded) → **100% GPU** ⚡ Maximum speed
- `llama3.2:3b` (2GB loaded) → **100% GPU** ⚡ Fits perfectly
- `deepseek-r1:8b` (6.2GB loaded) → **43% GPU / 57% CPU** - Automatically split

> 💡 **Note**: Performance will vary depending on your GPU model and available VRAM. Models that fit completely in VRAM will always run faster than split configurations.

### Enabling GPU Support

The `docker-compose.yml` is already configured for GPU support. To enable:

**1. Verify GPU is accessible:**
```bash
nvidia-smi
```

**2. For WSL2 (Windows):**
- Install NVIDIA GPU drivers for WSL2 from [nvidia.com](https://www.nvidia.com/Download/index.aspx)
- Docker Desktop automatically supports GPU passthrough

**3. For native Linux:**
Install NVIDIA Container Toolkit:
```bash
# Ubuntu/Debian
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**4. Verify GPU in container:**
```bash
docker exec -it n8n-sandbox nvidia-smi
```

**5. Check model GPU usage:**
```bash
docker exec -it n8n-sandbox ollama ps
```

The `PROCESSOR` column shows GPU usage (e.g., "100% GPU" or "43%/57% CPU/GPU").

### GPU Troubleshooting

- **"nvidia-smi: command not found"**: Install proper NVIDIA drivers for your OS/WSL2
- **No GPU shown in container**: Verify `docker run --gpus all ubuntu nvidia-smi` works
- **Model not using GPU**: Check `docker logs n8n-sandbox` for GPU detection messages

## 🚦 Usage

### With Docker Compose

Start the services:
```bash
docker-compose up -d
```

View logs:
```bash
docker-compose logs -f
```

Stop the services:
```bash
docker-compose down
```

### With Dev Container

1. Open the project in VS Code
2. Click "Reopen in Container" when prompted (or use Command Palette: `Dev Containers: Reopen in Container`)
3. Services will start automatically

## 📁 Project Structure

```
n8n-sandbox/
├── docker-compose.yml      # Docker services configuration
├── Dockerfile              # Container image definition
├── start-services.sh       # Service startup script
├── .gitignore             # Git exclusions (runtime data)
├── n8n_data/              # n8n persistent data (git-ignored)
│   ├── database.sqlite    # Workflow database
│   ├── nodes/             # Custom nodes
│   └── config             # n8n configuration
└── ollama_data/           # Ollama models and data (git-ignored)
    └── models/            # Downloaded LLM models
```

## 🔧 Configuration

- n8n data is stored in `./n8n_data` (not versioned - local only)
- Ollama models are stored in `./ollama_data/models` (not versioned - local only)
- Both directories are mounted as volumes to persist data between container restarts
- **Important**: These directories contain runtime data and credentials - they are excluded from git for security

## 💡 Tips

- Access n8n at http://localhost:5678 to create your first workflow
- Use the Ollama node in n8n to interact with local AI models
- Check Ollama documentation for available models: https://ollama.com/library

## 👤 Author

**aragong**
- GitHub: [@aragong](https://github.com/aragong)

## 📝 License

This is a sandbox environment for development and testing purposes.
