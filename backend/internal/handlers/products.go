package handlers

import (
	"encoding/json"
	"net/http"
	"time"
	"wms-backend/internal/database"
	"wms-backend/internal/models"
)

func GetProducts(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query("SELECT id, name, sku, category_id, description, price, created_at FROM warehouse_product ORDER BY name")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var p models.Product
		var createdAt time.Time
		rows.Scan(&p.ID, &p.Name, &p.SKU, &p.CategoryID, &p.Description, &p.Price, &createdAt)
		p.CreatedAt = createdAt.Format(time.RFC3339)
		products = append(products, p)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(products)
}

func CreateProduct(w http.ResponseWriter, r *http.Request) {
	var p models.Product
	if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	var createdAt time.Time
	err := database.DB.QueryRow(
		"INSERT INTO warehouse_product (name, sku, category_id, description, price) VALUES ($1, $2, $3, $4, $5) RETURNING id, created_at",
		p.Name, p.SKU, p.CategoryID, p.Description, p.Price,
	).Scan(&p.ID, &createdAt)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	p.CreatedAt = createdAt.Format(time.RFC3339)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(p)
}

func ProductsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetProducts(w, r)
	case "POST":
		CreateProduct(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}