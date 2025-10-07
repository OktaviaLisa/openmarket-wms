package handlers

import (
	"encoding/json"
	"net/http"
	"time"
	"wms-backend/internal/database"
	"wms-backend/internal/models"
)

func GetCategories(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query("SELECT id, name, description, created_at FROM warehouse_category ORDER BY name")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var categories []models.Category
	for rows.Next() {
		var c models.Category
		var createdAt time.Time
		rows.Scan(&c.ID, &c.Name, &c.Description, &createdAt)
		c.CreatedAt = createdAt.Format(time.RFC3339)
		categories = append(categories, c)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(categories)
}

func CreateCategory(w http.ResponseWriter, r *http.Request) {
	var c models.Category
	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	var createdAt time.Time
	err := database.DB.QueryRow(
		"INSERT INTO warehouse_category (name, description) VALUES ($1, $2) RETURNING id, created_at",
		c.Name, c.Description,
	).Scan(&c.ID, &createdAt)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	c.CreatedAt = createdAt.Format(time.RFC3339)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(c)
}

func CategoriesHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetCategories(w, r)
	case "POST":
		CreateCategory(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}