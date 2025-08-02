include .env
export

# Development commands
run:
	docker compose up --build

run-d:
	docker compose up -d --build

stop:
	docker compose down

db:
	docker compose exec db psql -U postgres

# Database migration commands
migrate-up:
	docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" up

migrate-down:
	docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" down -all

migrate-force:
	docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" force $(VERSION)

migrate-version:
	docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "postgres://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" version

migrate-create:
	docker run --rm \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		create -ext sql -dir /migrations -seq $(NAME)

# Production migration commands (for external databases)
# Note: Migrations should use direct connection, not pooling
migrate-up-prod:
	docker run --rm \
		--add-host=host.docker.internal:host-gateway \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DIRECT_URL)" up

migrate-down-prod:
	docker run --rm \
		--add-host=host.docker.internal:host-gateway \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DIRECT_URL)" down -all

migrate-version-prod:
	docker run --rm \
		--add-host=host.docker.internal:host-gateway \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DIRECT_URL)" version

# Supabase-specific migration commands (alternative approach)
migrate-up-supabase:
	docker run --rm \
		--network host \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DB_URL)" up

migrate-down-supabase:
	docker run --rm \
		--network host \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DB_URL)" down -all

migrate-version-supabase:
	docker run --rm \
		--network host \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DB_URL)" version

# Local migration commands (requires migrate tool installed locally)
migrate-up-local:
	migrate -path db/migrations -database "$(PROD_DIRECT_URL)" up

migrate-down-local:
	migrate -path db/migrations -database "$(PROD_DIRECT_URL)" down -all

migrate-version-local:
	migrate -path db/migrations -database "$(PROD_DIRECT_URL)" version

# Code generation
sqlc-docker:
	docker run --rm -v $(PWD):/src -w /src sqlc/sqlc:1.29.0 generate -f db/sqlc.yml

# Connection testing commands
test-direct-connection:
	@echo "Testing direct connection..."
	@docker run --rm ${DB_IMAGE} psql "$(PROD_DIRECT_URL)" -c "SELECT version();"

test-pooled-connection:
	@echo "Testing pooled connection..."
	@docker run --rm ${DB_IMAGE} psql "$(PROD_DB_URL)" -c "SELECT version();"

# Development workflow
dev-setup: migrate-up
	@echo "Development environment setup complete!"

dev-reset: migrate-down migrate-up
	@echo "Database reset complete!"

# Complete database reset (for development)
db-reset:
	@echo "Resetting database completely..."
	@docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "${DB_URL}" force 1 || true
	@docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "${DB_URL}" down -all || true
	@docker run --rm \
		--network=publicar-backend_publicar \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "${DB_URL}" up
	@echo "Database reset and migrations applied successfully!"

# Help
help:
	@echo "Available commands:"
	@echo "  run              - Start development environment"
	@echo "  run-detached     - Start development environment in background"
	@echo "  stop             - Stop development environment"
	@echo "  db               - Connect to database"
	@echo ""
	@echo "Migration commands:"
	@echo "  migrate-up       - Apply all pending migrations"
	@echo "  migrate-down     - Rollback all migrations"
	@echo "  migrate-force    - Force migration to specific version (VERSION=X)"
	@echo "  migrate-version  - Show current migration version"
	@echo "  migrate-create   - Create new migration (NAME=migration_name)"
	@echo ""
	@echo "Production commands:"
	@echo "  migrate-up-prod  - Apply migrations to production (PROD_DB_URL required)"
	@echo "  migrate-down-prod- Rollback production migrations (PROD_DB_URL required)"
	@echo "  migrate-version-prod - Show production migration version"
	@echo "  migrate-up-supabase - Apply migrations to Supabase (alternative network config)"
	@echo "  migrate-up-local   - Apply migrations locally (requires migrate tool)"
	@echo ""
	@echo "Development workflow:"
	@echo "  dev-setup        - Setup development environment"
	@echo "  dev-reset        - Reset database and reapply migrations"
	@echo "  db-reset         - Complete database reset (force reset + apply all migrations)"
	@echo "  sqlc             - Generate SQL code"
