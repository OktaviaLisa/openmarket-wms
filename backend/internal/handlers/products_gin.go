package handlers

import (
	"net/http"
	"wms-backend/internal/models"

	"github.com/gin-gonic/gin"
)

func (h *Handler) GetProductsGin(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, name, sku, category_id, description, price, stock, created_at FROM products ORDER BY id")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var product models.Product
		err := rows.Scan(&product.ID, &product.Name, &product.SKU, &product.CategoryID, &product.Description, &product.Price, &product.Stock, &product.CreatedAt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		products = append(products, product)
	}

	c.JSON(http.StatusOK, products)
}

func (h *Handler) CreateProductGin(c *gin.Context) {
	var product models.Product
	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	if product.Name == "" || product.SKU == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Name and SKU are required"})
		return
	}

	var productID int
	err := h.DB.QueryRow(
		"INSERT INTO products (name, sku, category_id, description, price, stock, created_at) VALUES ($1, $2, $3, $4, $5, $6, NOW()) RETURNING id",
		product.Name, product.SKU, product.CategoryID, product.Description, product.Price, product.Stock,
	).Scan(&productID)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Product already exists or invalid data"})
		return
	}

	product.ID = productID
	c.JSON(http.StatusCreated, product)
}

func (h *Handler) GetCategoriesGin(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, name, description, created_at FROM categories ORDER BY id")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var categories []models.Category
	for rows.Next() {
		var category models.Category
		err := rows.Scan(&category.ID, &category.Name, &category.Description, &category.CreatedAt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		categories = append(categories, category)
	}

	c.JSON(http.StatusOK, categories)
}