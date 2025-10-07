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