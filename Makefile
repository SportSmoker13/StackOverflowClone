# Makefile
.PHONY: help setup dev-up dev-down dev-logs prod-up prod-down clean

help:
	@echo "Stack Overflow Clone - Docker Commands"
	@echo "======================================"
	@echo "make setup       - Initial setup"
	@echo "make dev-up      - Start development environment"
	@echo "make dev-down    - Stop development environment"
	@echo "make dev-logs    - View development logs"
	@echo "make prod-up     - Start production environment"
	@echo "make prod-down   - Stop production environment"
	@echo "make clean       - Remove all containers and volumes"

setup:
	cp .env.example .env
	@echo "Please update .env with your SECRET_KEY_BASE"
	@echo "Generate with: mix phx.gen.secret"

dev-up:
	docker-compose up -d
	@echo "Application starting at http://localhost:4000"

dev-down:
	docker-compose down

dev-logs:
	docker-compose logs -f web

prod-up:
	docker-compose -f docker-compose.prod.yml up -d

prod-down:
	docker-compose -f docker-compose.prod.yml down

clean:
	docker-compose down -v
	docker-compose -f docker-compose.prod.yml down -v
