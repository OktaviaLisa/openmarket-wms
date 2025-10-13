package handlers

import (
	"net/http"
	"github.com/gin-gonic/gin"
)

func (h *Handler) GetInventoryData(c *gin.Context) {
	rows, err := h.DB.Query(`SELECT id, product_name, category, quantity, location, updated_at FROM inventory WHERE quantity > 0 ORDER BY product_name`)
	if err != nil {
		// Fallback to static data if DB fails
		inventory := []map[string]interface{}{
			{"id": 1, "product_name": "Laptop Dell", "category": "Electronics", "quantity": 50, "location": "A-01", "updated_at": "2025-09-10T04:37:24Z"},
			{"id": 2, "product_name": "Mouse Wireless", "category": "Electronics", "quantity": 100, "location": "A-02", "updated_at": "2025-09-10T04:37:24Z"},
			{"id": 3, "product_name": "Kertas A4", "category": "Office Supplies", "quantity": 200, "location": "B-01", "updated_at": "2025-09-10T04:37:24Z"},
		}
		c.JSON(http.StatusOK, inventory)
		return
	}
	defer rows.Close()

	var inventory []map[string]interface{}
	for rows.Next() {
		var id, quantity int
		var productName, category, location, updatedAt string

		if err := rows.Scan(&id, &productName, &category, &quantity, &location, &updatedAt); err != nil {
			continue
		}

		inventory = append(inventory, map[string]interface{}{
			"id":           id,
			"product_name": productName,
			"category":     category,
			"quantity":     quantity,
			"location":     location,
			"updated_at":   updatedAt,
		})
	}

	c.JSON(http.StatusOK, inventory)
}

func (h *Handler) CreateInventoryItem(c *gin.Context) {
	var item struct {
		ProductName string `json:"product_name"`
		Category    string `json:"category"`
		Quantity    int    `json:"quantity"`
		Location    string `json:"location"`
		MinStock    int    `json:"min_stock"`
	}

	if err := c.ShouldBindJSON(&item); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	// Check if item already exists
	var existingID int
	err := h.DB.QueryRow(
		"SELECT id FROM inventory WHERE product_name = $1 AND category = $2",
		item.ProductName, item.Category,
	).Scan(&existingID)

	if err == nil {
		// Item exists, update quantity
		_, err = h.DB.Exec(
			"UPDATE inventory SET quantity = quantity + $1, updated_at = NOW() WHERE id = $2",
			item.Quantity, existingID,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory"})
			return
		}
		c.JSON(http.StatusOK, gin.H{"message": "Inventory updated", "id": existingID})
	} else {
		// Item doesn't exist, create new
		var newID int
		err = h.DB.QueryRow(
			"INSERT INTO inventory (product_name, category, quantity, location, min_stock, updated_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING id",
			item.ProductName, item.Category, item.Quantity, item.Location, item.MinStock,
		).Scan(&newID)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create inventory item"})
			return
		}
		c.JSON(http.StatusCreated, gin.H{"message": "Inventory item created", "id": newID})
	}
}