package main

import (
	"context"
	"log"

	"github.com/Colding-Team/PubliCar-Backend/internal/db"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()
	ctx := context.Background()

	db, err := db.NewDB(ctx)
	if err != nil {
		log.Fatalf("Erro ao conectar ao banco: %v", err)
	}
	defer db.Close()
}
