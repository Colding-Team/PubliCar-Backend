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
migrate-up-prod:
	docker run --rm \
		--network host \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DB_URL)" up

migrate-down-prod:
	docker run --rm \
		--network host \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DB_URL)" down -all

migrate-version-prod:
	docker run --rm \
		--network host \
		-v $(PWD)/db/migrations:/migrations migrate/migrate \
		-path=/migrations \
		-database "$(PROD_DB_URL)" version

# Code generation
sqlc-docker:
	docker run --rm -v $(PWD):/src -w /src sqlc/sqlc:1.29.0 generate -f db/sqlc.yml

# Database schema export
schema-dump:
	docker run --rm \
		--network=publicar-backend_publicar \
		-e PGPASSWORD=dev \
		${DB_IMAGE} \
		pg_dump ${DB_URL} \
		--schema-only --no-owner --no-privileges \
		> db/schema.sql

schema-dump-prod:
	@echo "Exporting schema from production database..."
	@docker run --rm \
		${DB_IMAGE} \
		pg_dump "$(PROD_DB_URL)" \
		--schema-only --no-owner --no-privileges \
		> db/schema.sql
	@echo "Schema exported to db/schema.sql"

# Connection testing commands
test-prod-connection:
	@echo "Testing production connection..."
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

# Complete migration and SQLC sync workflow
migrate-sync: migrate-up schema-dump sqlc-docker
	@echo "✅ Migration and SQLC sync completed successfully!"

migrate-sync-prod: migrate-up-prod schema-dump-prod sqlc-docker
	@echo "✅ Production migration and SQLC sync completed successfully!"

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
	@echo "  test-prod-connection - Test production database connection"
	@echo ""
	@echo "Development workflow:"
	@echo "  dev-setup        - Setup development environment"
	@echo "  dev-reset        - Reset database and reapply migrations"
	@echo "  db-reset         - Complete database reset (force reset + apply all migrations)"
	@echo "  sqlc-docker      - Generate SQL code using Docker"
	@echo ""
	@echo "Migration sync workflow:"
	@echo "  migrate-sync     - Apply migrations + export schema + generate SQLC (dev)"
	@echo "  migrate-sync-prod- Apply migrations + export schema + generate SQLC (prod)"
	@echo ""
	@echo "Schema export:"
	@echo "  schema-dump      - Export schema from development database"
	@echo "  schema-dump-prod - Export schema from production database"
