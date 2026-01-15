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
- At least 8GB of RAM (recommended for running AI models)
- ~5GB of free disk space for models

## 🛠️ Services

When the container starts, the following services are automatically launched:

| Service | URL | Description |
|---------|-----|-------------|
| **n8n** | http://localhost:5678 | Workflow automation platform |
| **Ollama API** | http://localhost:11434 | Local LLM inference server |

## 🤖 Ollama Models

The container automatically checks if there are any Ollama models installed. If none are found, it will automatically download the `deepseek-r1:8b` model on first startup.

### Managing Models

To install additional models, run:
```bash
docker exec -it n8n-sandbox-ollama-1 ollama pull <model-name>
```

To list installed models:
```bash
docker exec -it n8n-sandbox-ollama-1 ollama list
```

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

## 📝 License

This is a sandbox environment for development and testing purposes.
