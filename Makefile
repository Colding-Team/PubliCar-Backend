include .env
export

run:
	docker compose up --build

db:
	docker compose exec db psql -U postgres

sqlc:
	sqlc generate --file db/sqlc.yml

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

migrate-create:
	migrate create -ext sql -dir db/migrations -seq
