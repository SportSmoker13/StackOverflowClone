# Stack Overflow Clone with AI Ranking

A Phoenix LiveView application that searches Stack Overflow questions and uses local AI (Ollama) to re-rank answers by relevance and quality.

## What It Does

1. **Search Stack Overflow**: Enter any programming question
2. **View Answers**: See the question with all its answers
3. **Original Ranking**: Answers sorted by Stack Overflow votes
4. **AI-Powered Ranking**: Answers re-ranked by local LLM based on accuracy, completeness, and clarity
5. **Search History**: Automatically saves your last 5 searches

## Tech Stack

- **Backend**: Elixir + Phoenix + LiveView
- **Database**: PostgreSQL
- **AI**: Ollama (local LLM - runs on your machine, no API keys needed)
- **Styling**: TailwindCSS
- **Infrastructure**: Docker + Docker Compose

## Prerequisites

- Docker
- Docker Compose

That's it! Everything else runs in containers.

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/SportSmoker13/StackOverflowClone
cd stackoverflow_clone
```

### 2. Create environment file

```bash
cp .env.example .env
```

### 3. Generate secret key

```bash
mix phx.gen.secret
```

Copy the output and paste it in `.env` as `SECRET_KEY_BASE`

### 4. Start everything

```bash
docker-compose up -d
```

### 5. Wait for model download (first time only, takes 5-10 minutes)

```bash
docker-compose logs -f ollama-setup
```

### 6. Open browser

```bash
open http://localhost:4000
```

## Usage

1. Type a question in the search box (e.g., "How to reverse a string in Python")
2. View answers with original Stack Overflow ranking
3. Click "LLM Ranked" tab to see AI-reranked answers
4. Each LLM ranking includes reasoning for why it was ranked that way

## Configuration

### Use a Faster Model (Optional)

If llama2 is too slow, use a smaller model:

```bash
# Pull smaller model (157MB vs 3.8GB)
docker-compose exec ollama ollama pull tinyllama

# Update .env
LLM_MODEL=tinyllama

# Restart
docker-compose restart web
```

## Common Commands

```bash
# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Restart
docker-compose restart web

# Complete reset
docker-compose down -v
docker-compose up -d
```

## Troubleshooting

### Model not found error?

```bash
docker-compose exec ollama ollama pull llama2
docker-compose restart web
```

### Port 4000 already in use?

Change port in `docker-compose.yml`:

```yaml
ports:
  - "4001:4000"
```

### Can't connect to Ollama?

```bash
docker-compose restart ollama
sleep 30
docker-compose restart web
```

## Project Structure

```
stackoverflow_clone/
├── lib/
│   ├── stackoverflow_clone/          # Business logic
│   │   ├── clients/                  # Stack Overflow & LLM API clients
│   │   ├── search.ex                 # Search management
│   │   ├── stack_overflow.ex         # Questions & answers
│   │   └── llm.ex                    # AI ranking logic
│   └── stackoverflow_clone_web/
│       └── live/                     # LiveView UI
├── priv/repo/migrations/             # Database schemas
├── docker-compose.yml                # Service definitions
└── .env                              # Configuration
```

## License

MIT