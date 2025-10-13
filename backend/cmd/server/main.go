package main

import (
	"log"

	"wms-backend/internal/config"
	"wms-backend/internal/database"
	"wms-backend/internal/handlers"
)

func main() {
	cfg := config.Load()

	log.Println("Go Backend Server starting on 0.0.0.0:" + cfg.Port)

	// Connect to database
	if err := database.Connect(cfg.DatabaseURL); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Create handler with database connection
	h := handlers.NewHandler(database.DB)

	// Setup routes
	r := handlers.SetupRoutes(h)

	log.Printf("Server running on http://localhost:%s", cfg.Port)
	r.Run("0.0.0.0:" + cfg.Port)
}
