package handlers

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"wms-backend/internal/middleware"
)

func SetupRoutes(h *Handler) *gin.Engine {
	r := gin.Default()
	
	// CORS middleware
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
		
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		
		c.Next()
	})

	// Health check endpoint
	r.GET("/api/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok", "service": "wms-backend"})
	})
	
	api := r.Group("/api")
	{
		// Auth routes
		api.POST("/auth/login", h.LoginGin)
		api.POST("/auth/register", h.RegisterGin)
		
		// Goods Receipt routes
		api.POST("/penerimaan", h.CreatePenerimaan)
		api.GET("/penerimaan", h.GetPenerimaan)
		api.POST("/penerimaan/:id/detail", h.AddDetailPenerimaan)
		api.GET("/penerimaan/:id/detail", h.GetDetailPenerimaan)
		api.POST("/detail/:detailId/pemeriksaan", h.CreatePemeriksaanKualitas)
		api.PUT("/penerimaan/:id/complete", h.CompletePenerimaan)
		
		// Inventory Management routes
		api.GET("/inventory", h.GetInventoryData)
		api.POST("/inventory", h.CreateInventoryItem)
		api.GET("/stock-opnames", h.GetStockOpnames)
		api.POST("/stock-opnames", h.CreateStockOpname)
		api.GET("/stock-movements", h.GetStockMovements)
		api.POST("/stock-movements", h.CreateStockMovement)
		api.GET("/receptions", h.GetReceptions)
		api.POST("/receptions", h.CreateReception)
		api.PUT("/receptions/:id/status", h.UpdateReceptionStatus)
		api.GET("/dispatches", h.GetDispatches)
		api.POST("/dispatches", h.CreateDispatch)
		api.GET("/returns", h.GetReturns)
		api.POST("/returns", h.CreateReturn)
		api.GET("/quality-checks", h.GetQualityChecksSimple)
		api.POST("/quality-checks", h.CreateQualityCheckRecord)
		api.GET("/inventory-monitoring", h.GetInventoryMonitoring)
		
		// Transaction routes
		api.POST("/receiving", h.CreateReceiving)
		api.GET("/receiving", h.GetReceivings)
		api.POST("/issuing", h.CreateIssuing)
		api.GET("/issuing", h.GetIssuings)
		
		// Master data routes
		api.GET("/suppliers", h.GetSuppliers)
		api.GET("/customers", h.GetCustomers)
		api.GET("/units", h.GetUnits)
		api.GET("/locations", h.GetLocations)
		
		// Protected routes
		protected := api.Group("/")
		protected.Use(middleware.AuthGin())
		{
			protected.GET("/users", h.GetUsersGin)
			protected.POST("/users", h.CreateUserGin)
			protected.GET("/products", h.GetProductsGin)
			protected.POST("/products", h.CreateProductGin)
			protected.GET("/categories", h.GetCategoriesGin)
		}
	}

	return r
}





func (h *Handler) CreateDispatch(c *gin.Context) {
	var req struct {
		ProductName string `json:"product_name" binding:"required"`
		Customer    string `json:"customer"`
		Quantity    int    `json:"quantity" binding:"required"`
		Location    string `json:"location"`
		Notes       string `json:"notes"`
		Status      string `json:"status"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Use provided status or default to pending
	status := req.Status
	if status == "" {
		status = "pending"
	}

	// Insert dispatch record
	var dispatchID int
	err := h.DB.QueryRow(`
		INSERT INTO dispatches (product_name, customer, quantity, location, notes, dispatch_date, status)
		VALUES ($1, $2, $3, $4, $5, NOW(), $6)
		RETURNING id`,
		req.ProductName, req.Customer, req.Quantity, req.Location, req.Notes, status,
	).Scan(&dispatchID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create dispatch"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"id": dispatchID,
		"message": "Dispatch created successfully",
	})
}

// Stub handlers
func (h *Handler) GetStockOpnames(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Stock opnames endpoint"})
}

func (h *Handler) CreateStockOpname(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"message": "Stock opname created"})
}

func (h *Handler) GetStockMovements(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Stock movements endpoint"})
}

func (h *Handler) CreateStockMovement(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"message": "Stock movement created"})
}

func (h *Handler) CreateReception(c *gin.Context) {
	var req struct {
		ProductName string `json:"product_name" binding:"required"`
		Category    string `json:"category"`
		Quantity    int    `json:"quantity" binding:"required"`
		Location    string `json:"location"`
		Notes       string `json:"notes"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Always use quality_check for receptions
	status := "quality_check"

	// Insert reception record
	var receptionID int
	err := h.DB.QueryRow(`
		INSERT INTO receptions (product_name, category, quantity, location, notes, received_date, status)
		VALUES ($1, $2, $3, $4, $5, NOW(), $6)
		RETURNING id`,
		req.ProductName, req.Category, req.Quantity, req.Location, req.Notes, status,
	).Scan(&receptionID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create reception"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"id": receptionID,
		"message": "Reception created successfully",
	})
}

func (h *Handler) GetReceptions(c *gin.Context) {
	rows, err := h.DB.Query(`
		SELECT id, product_name, category, quantity, location, notes, received_date, status
		FROM receptions
		ORDER BY received_date DESC`)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch receptions"})
		return
	}
	defer rows.Close()
	
	var receptions []map[string]interface{}
	for rows.Next() {
		var id int
		var productName, category, location, notes, status string
		var quantity int
		var receivedDate string
		
		err := rows.Scan(&id, &productName, &category, &quantity, &location, &notes, &receivedDate, &status)
		if err != nil {
			continue
		}
		
		receptions = append(receptions, map[string]interface{}{
			"id": id,
			"product_name": productName,
			"supplier": category,
			"quantity": quantity,
			"location": location,
			"notes": notes,
			"date": receivedDate[:10],
			"status": status,
		})
	}
	
	c.JSON(http.StatusOK, receptions)
}

func (h *Handler) UpdateReceptionStatus(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Reception status updated"})
}

func (h *Handler) GetDispatches(c *gin.Context) {
	rows, err := h.DB.Query(`
		SELECT id, product_name, customer, quantity, location, notes, dispatch_date, status
		FROM dispatches
		ORDER BY dispatch_date DESC`)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch dispatches"})
		return
	}
	defer rows.Close()
	
	var dispatches []map[string]interface{}
	for rows.Next() {
		var id int
		var productName, customer, location, notes, status string
		var quantity int
		var dispatchDate string
		
		err := rows.Scan(&id, &productName, &customer, &quantity, &location, &notes, &dispatchDate, &status)
		if err != nil {
			continue
		}
		
		dispatches = append(dispatches, map[string]interface{}{
			"id": id,
			"product_name": productName,
			"customer": customer,
			"quantity": quantity,
			"location": location,
			"notes": notes,
			"created_at": dispatchDate[:10],
			"status": status,
		})
	}
	
	c.JSON(http.StatusOK, dispatches)
}

func (h *Handler) GetReturns(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Returns endpoint"})
}

func (h *Handler) CreateReturn(c *gin.Context) {
	c.JSON(http.StatusCreated, gin.H{"message": "Return created"})
}

func (h *Handler) GetQualityChecks(c *gin.Context) {
	rows, err := h.DB.Query(`SELECT id, reception_id, product_name, quantity, status, COALESCE(notes, '') FROM quality_checks ORDER BY checked_at DESC`)
	
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

func (h *Handler) CreateQualityCheckRecord(c *gin.Context) {
	var req struct {
		ReceptionID int    `json:"reception_id" binding:"required"`
		ProductName string `json:"product_name" binding:"required"`
		Quantity    int    `json:"quantity" binding:"required"`
		Status      string `json:"status" binding:"required"`
		Notes       string `json:"notes"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Insert or update quality check record
	var qcID int
	err := h.DB.QueryRow(`
		INSERT INTO quality_checks (reception_id, product_name, quantity, status, notes, checked_at)
		VALUES ($1, $2, $3, $4, $5, NOW())
		ON CONFLICT (reception_id) DO UPDATE SET
			status = EXCLUDED.status,
			notes = EXCLUDED.notes,
			checked_at = NOW()
		RETURNING id`,
		req.ReceptionID, req.ProductName, req.Quantity, req.Status, req.Notes,
	).Scan(&qcID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create quality check record"})
		return
	}

	// Jika status PASS, tambahkan ke inventory
	if req.Status == "PASS" {
		// Buat warehouse_product baru untuk setiap quality check
		_, err = h.DB.Exec(`
			INSERT INTO warehouse_product (id, name, sku, price, description, created_at)
			VALUES ($1, $2, $3, 0, 'Product from QC', NOW())
			ON CONFLICT (id) DO NOTHING`,
			qcID, req.ProductName, "QC-"+string(rune(qcID)))
		
		// Insert data baru ke inventory dengan product_id = qcID
		_, err = h.DB.Exec(`
			INSERT INTO inventory (product_id, quantity, min_stock, location_id, quality_check_id, updated_at)
			VALUES ($1, $2, 0, 1, $3, NOW())`,
			qcID, req.Quantity, qcID)
		
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add to inventory: " + err.Error()})
			return
		}
		
		// Update reception status ke completed
		_, err = h.DB.Exec(`UPDATE receptions SET status = 'completed' WHERE id = $1`, req.ReceptionID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update reception status"})
			return
		}
	}

	c.JSON(http.StatusCreated, gin.H{
		"id": qcID,
		"message": "Quality check completed and inventory updated",
	})
}

func (h *Handler) GetInventoryMonitoring(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"message": "Inventory monitoring endpoint"})
}

