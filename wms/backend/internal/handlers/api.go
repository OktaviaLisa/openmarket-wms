package handlers

import (
	"encoding/json"
	"net/http"
)

func APIRoot(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"message": "WMS API Server",
		"version": "1.0.0",
		"endpoints": map[string]string{
			"auth":              "/api/auth/login",
			"products":          "/api/products",
			"categories":        "/api/categories",
			"users":             "/api/users",
			"inventory":         "/api/inventory",
			"stock-movements":   "/api/stock-movements",
			"stock-opnames":     "/api/stock-opnames",
			"receptions":        "/api/receptions",
			"dispatches":        "/api/dispatches",
			"returns":           "/api/returns",
			"quality-checks":    "/api/quality-checks",
			"reports":           "/api/reports",
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}