#!/bin/bash

source .env

set -euo pipefail

DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_HOST="${DB_HOST}"
DB_PORT="${DB_PORT}"
BACKUP_DIR="./db/backups"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${BACKUP_DIR}/backup_${DB_NAME}_${TIMESTAMP}.sql"

mkdir -p "$BACKUP_DIR"

echo "🔄 Gerando backup de ${DB_NAME}..."
PGPASSWORD="${DB_PASSWORD}" pg_dump \
	-h "$DB_HOST" \
	-U "$DB_USER" \
	-p "$DB_PORT" \
	-d "$DB_NAME" \
	--no-owner \
	--format=plain \
	--file="$FILENAME"

echo "✅ Backup salvo em: $FILENAME"
