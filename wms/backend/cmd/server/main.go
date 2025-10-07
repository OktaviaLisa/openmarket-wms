package main

import (
	"log"
	"wms-backend/internal/config"
	"wms-backend/internal/database"
	"wms-backend/internal/handlers"
)

func main() {
	cfg := config.Load()

	// Connect directly to PostgreSQL database
	if err := database.Connect(cfg.DatabaseURL); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Create handler with database connection
	h := handlers.NewHandler(database.DB)

	// Setup Gin routes
	r := handlers.SetupRoutes(h)

	log.Printf("Go Backend Server starting on 0.0.0.0:%s", cfg.Port)
	log.Fatal(r.Run("0.0.0.0:" + cfg.Port))
}