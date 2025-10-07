# Stack Overflow Clone

A full-featured Stack Overflow clone built with Phoenix Framework and AI-powered features using Ollama LLM.

## Table of Contents
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Development](#development)
- [Production Deployment](#production-deployment)
- [API Endpoints](#api-endpoints)
- [Contributing](#contributing)
- [License](#license)

## Tech Stack

- **Phoenix Framework** (Backend)
- **PostgreSQL** (Database)
- **Ollama LLM** (AI Features)
- **Docker & Docker Compose** (Containerization)
- **LiveView** (Real-time features)

## Prerequisites

- Docker Desktop for Mac
- Elixir 1.16+ (optional for local development)
- Make (optional)

## Quick Start

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/yourusername/stackoverflow_clone.git](https://github.com/yourusername/stackoverflow_clone.git)
    cd stackoverflow_clone
    ```

2.  **Setup environment:**
    ```bash
    cp .env.example .env
    ```

3.  **Start development environment:**
    ```bash
    # Using Make
    make dev-up

    # or without Make
    docker compose up -d
    ```

4.  **Visit the application:**
    Open your browser and go to `http://localhost:4000`.

## Development

### Start Services

```bash
# Start all services
make dev-up

# View logs
make dev-logs

# Stop services
make dev-down

## Database Operations

# Check Ollama health
curl http://localhost:11434/api/health

# Pull a model (e.g., llama2)
docker compose exec ollama ollama pull llama2# StackOverflowClone
