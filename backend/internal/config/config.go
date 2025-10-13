package config

import "os"

type Config struct {
	DatabaseURL string
	APIURL      string
	JWTSecret   string
	Port        string
}

func Load() *Config {
	return &Config{
		DatabaseURL: getEnv("DATABASE_URL", "postgres://wms_user:wms_password@db:5432/wms_db?sslmode=disable"),
		APIURL:      getEnv("API_URL", "http://localhost:8000"),
		JWTSecret:   getEnv("JWT_SECRET", "your-secret-key"),
		Port:        getEnv("PORT", "8000"),
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
