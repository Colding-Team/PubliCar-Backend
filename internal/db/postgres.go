package db

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

type DB struct {
	Pool *pgxpool.Pool
	*Queries
}

// NewDB cria uma nova conexão com o banco e retorna a estrutura DB.
// A URL do banco deve ser passada via variável de ambiente DB_URL.
// Para produção com Supabase, use a URL do pooler (PROD_DB_URL) para melhor performance.
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

	fmt.Printf("Conexão com o banco estabelecida com sucesso: %s\n", dbURL)

	return &DB{
		Pool:    pool,
		Queries: queries,
	}, nil
}

// Close encerra a conexão com o banco.
func (db *DB) Close() {
	db.Pool.Close()
}
