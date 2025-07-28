package db

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

// DB encapsula a pool do pgx e os métodos gerados pelo sqlc.
type DB struct {
	Pool *pgxpool.Pool
	*Queries
}

// NewDB cria uma nova conexão com o banco e retorna a estrutura DB.
// A URL do banco deve ser passada via variável de ambiente DATABASE_URL.
func NewDB(ctx context.Context) (*DB, error) {
	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("variável de ambiente DB_URL não definida")
	}

	cfg, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		return nil, fmt.Errorf("erro ao parsear DATABASE_URL: %w", err)
	}

	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("erro ao criar pool pgx: %w", err)
	}

	queries := New(pool)

	return &DB{
		Pool:    pool,
		Queries: queries,
	}, nil
}

// Close encerra a conexão com o banco.
func (db *DB) Close() {
	db.Pool.Close()
}
