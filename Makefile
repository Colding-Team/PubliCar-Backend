run:
	docker compose up --build

db:
	docker compose exec db psql -U postgres

sqlc:
	sqlc generate --file db/sqlc.yml
