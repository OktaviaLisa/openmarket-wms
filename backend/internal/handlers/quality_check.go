package handlers

import (
	"net/http"
	"time"
	"wms-backend/internal/database"
	"wms-backend/internal/models"

	"github.com/gin-gonic/gin"
)

// Get all quality checks
func GetQualityCheck(c *gin.Context) {
	rows, err := database.DB.Query(`SELECT id, reception_id, product_name, quantity, status, notes, checked_at FROM quality_checks`)
	if err != nil {
    c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
    return
}
	defer rows.Close()

	var checks []models.QualityCheck
	for rows.Next() {
		var qc models.QualityCheck
		if err := rows.Scan(&qc.ID, &qc.ReceptionID, &qc.ProductName, &qc.Quantity, &qc.Status, &qc.Notes, &qc.CheckedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		checks = append(checks, qc)
	}

	c.JSON(http.StatusOK, checks)
}

// Create new quality check
func CreateQualityCheck(c *gin.Context) {
	var input models.QualityCheck
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	input.CheckedAt = time.Now()

	_, err := database.DB.Exec(`
		INSERT INTO quality_checks (reception_id, product_name, quantity, status, notes, checked_at)
		VALUES ($1, $2, $3, $4, $5, $6)
	`, input.ReceptionID, input.ProductName, input.Quantity, input.Status, input.Notes, input.CheckedAt)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Quality check created successfully"})
}
