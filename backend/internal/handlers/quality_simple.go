package handlers

import (
	"net/http"
	"github.com/gin-gonic/gin"
)

func (h *Handler) GetQualityChecksSimple(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, reception_id, product_name, quantity, status, COALESCE(notes, '') FROM quality_checks ORDER BY checked_at DESC")
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error: " + err.Error()})
		return
	}
	defer rows.Close()
	
	var results []map[string]interface{}
	for rows.Next() {
		var id, receptionID, quantity int
		var productName, status, notes string
		
		if err := rows.Scan(&id, &receptionID, &productName, &quantity, &status, &notes); err != nil {
			continue
		}
		
		results = append(results, map[string]interface{}{
			"id": id,
			"reception_id": receptionID,
			"product_name": productName,
			"quantity": quantity,
			"status": status,
			"notes": notes,
		})
	}
	
	c.JSON(http.StatusOK, results)
}