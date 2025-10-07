package handlers

import (
	"fmt"
	"net/http"
	"time"
	"wms-backend/internal/models"

	"github.com/gin-gonic/gin"
)

// Receiving Handlers
func (h *Handler) CreateReceiving(c *gin.Context) {
	var req models.ReceivingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Generate document number
	docNumber := fmt.Sprintf("RCV-%d", time.Now().Unix())

	// Parse date
	receiveDate, err := time.Parse("2006-01-02", req.ReceiveDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format"})
		return
	}

	// Begin transaction
	tx, err := h.DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Insert receiving record
	var receivingID int
	err = tx.QueryRow(`
		INSERT INTO receiving (document_number, receive_date, supplier_id, product_id, quantity, unit_id, location_id, remarks, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 1)
		RETURNING id
	`, docNumber, receiveDate, req.SupplierID, req.ProductID, req.Quantity, req.UnitID, req.LocationID, req.Remarks).Scan(&receivingID)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create receiving record"})
		return
	}

	// Update inventory
	_, err = tx.Exec(`
		INSERT INTO inventory (product_id, quantity, location_id, updated_at)
		VALUES ($1, $2, $3, NOW())
		ON CONFLICT (product_id, location_id)
		DO UPDATE SET quantity = inventory.quantity + $2, updated_at = NOW()
	`, req.ProductID, req.Quantity, req.LocationID)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory"})
		return
	}

	// Insert stock movement
	_, err = tx.Exec(`
		INSERT INTO stock_movements (product_id, movement_type, quantity, reference, created_at)
		VALUES ($1, 'IN', $2, $3, NOW())
	`, req.ProductID, req.Quantity, docNumber)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record stock movement"})
		return
	}

	if err = tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Receiving created successfully",
		"id": receivingID,
		"document_number": docNumber,
	})
}

func (h *Handler) GetReceivings(c *gin.Context) {
	rows, err := h.DB.Query(`
		SELECT r.id, r.document_number, r.receive_date, r.quantity, r.remarks, r.created_at,
			   s.name as supplier_name, p.name as product_name, u.symbol as unit_symbol, l.name as location_name
		FROM receiving r
		JOIN suppliers s ON r.supplier_id = s.id
		JOIN warehouse_product p ON r.product_id = p.id
		JOIN units u ON r.unit_id = u.id
		JOIN locations l ON r.location_id = l.id
		ORDER BY r.created_at DESC
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch receivings"})
		return
	}
	defer rows.Close()

	var receivings []models.Receiving
	for rows.Next() {
		var r models.Receiving
		err := rows.Scan(&r.ID, &r.DocumentNumber, &r.ReceiveDate, &r.Quantity, &r.Remarks, &r.CreatedAt,
			&r.SupplierName, &r.ProductName, &r.UnitSymbol, &r.LocationName)
		if err != nil {
			continue
		}
		receivings = append(receivings, r)
	}

	c.JSON(http.StatusOK, gin.H{"data": receivings})
}

// Issuing Handlers
func (h *Handler) CreateIssuing(c *gin.Context) {
	var req models.IssuingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check stock availability
	var currentStock int
	err := h.DB.QueryRow(`
		SELECT COALESCE(SUM(quantity), 0) FROM inventory 
		WHERE product_id = $1 AND location_id = $2
	`, req.ProductID, req.LocationID).Scan(&currentStock)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check stock"})
		return
	}

	if currentStock < req.Quantity {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Insufficient stock"})
		return
	}

	// Generate document number
	docNumber := fmt.Sprintf("ISS-%d", time.Now().Unix())

	// Parse date
	issueDate, err := time.Parse("2006-01-02", req.IssueDate)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format"})
		return
	}

	// Begin transaction
	tx, err := h.DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to start transaction"})
		return
	}
	defer tx.Rollback()

	// Insert issuing record
	var issuingID int
	err = tx.QueryRow(`
		INSERT INTO issuing (document_number, issue_date, customer_id, product_id, quantity, unit_id, location_id, remarks, created_by)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 1)
		RETURNING id
	`, docNumber, issueDate, req.CustomerID, req.ProductID, req.Quantity, req.UnitID, req.LocationID, req.Remarks).Scan(&issuingID)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create issuing record"})
		return
	}

	// Update inventory
	_, err = tx.Exec(`
		UPDATE inventory SET quantity = quantity - $1, updated_at = NOW()
		WHERE product_id = $2 AND location_id = $3
	`, req.Quantity, req.ProductID, req.LocationID)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update inventory"})
		return
	}

	// Insert stock movement
	_, err = tx.Exec(`
		INSERT INTO stock_movements (product_id, movement_type, quantity, reference, created_at)
		VALUES ($1, 'OUT', $2, $3, NOW())
	`, req.ProductID, req.Quantity, docNumber)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record stock movement"})
		return
	}

	if err = tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to commit transaction"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Issuing created successfully",
		"id": issuingID,
		"document_number": docNumber,
	})
}

func (h *Handler) GetIssuings(c *gin.Context) {
	rows, err := h.DB.Query(`
		SELECT i.id, i.document_number, i.issue_date, i.quantity, i.remarks, i.created_at,
			   c.name as customer_name, p.name as product_name, u.symbol as unit_symbol, l.name as location_name
		FROM issuing i
		JOIN customers c ON i.customer_id = c.id
		JOIN warehouse_product p ON i.product_id = p.id
		JOIN units u ON i.unit_id = u.id
		JOIN locations l ON i.location_id = l.id
		ORDER BY i.created_at DESC
	`)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch issuings"})
		return
	}
	defer rows.Close()

	var issuings []models.Issuing
	for rows.Next() {
		var i models.Issuing
		err := rows.Scan(&i.ID, &i.DocumentNumber, &i.IssueDate, &i.Quantity, &i.Remarks, &i.CreatedAt,
			&i.CustomerName, &i.ProductName, &i.UnitSymbol, &i.LocationName)
		if err != nil {
			continue
		}
		issuings = append(issuings, i)
	}

	c.JSON(http.StatusOK, gin.H{"data": issuings})
}

// Master Data Handlers
func (h *Handler) GetSuppliers(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, name, contact_person, phone, email FROM suppliers ORDER BY name")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch suppliers"})
		return
	}
	defer rows.Close()

	var suppliers []models.Supplier
	for rows.Next() {
		var s models.Supplier
		err := rows.Scan(&s.ID, &s.Name, &s.ContactPerson, &s.Phone, &s.Email)
		if err != nil {
			continue
		}
		suppliers = append(suppliers, s)
	}

	c.JSON(http.StatusOK, gin.H{"data": suppliers})
}

func (h *Handler) GetCustomers(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, name, contact_person, phone, email FROM customers ORDER BY name")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch customers"})
		return
	}
	defer rows.Close()

	var customers []models.Customer
	for rows.Next() {
		var c models.Customer
		err := rows.Scan(&c.ID, &c.Name, &c.ContactPerson, &c.Phone, &c.Email)
		if err != nil {
			continue
		}
		customers = append(customers, c)
	}

	c.JSON(http.StatusOK, gin.H{"data": customers})
}

func (h *Handler) GetUnits(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, name, symbol FROM units ORDER BY name")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch units"})
		return
	}
	defer rows.Close()

	var units []models.Unit
	for rows.Next() {
		var u models.Unit
		err := rows.Scan(&u.ID, &u.Name, &u.Symbol)
		if err != nil {
			continue
		}
		units = append(units, u)
	}

	c.JSON(http.StatusOK, gin.H{"data": units})
}

func (h *Handler) GetLocations(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, name, code, description FROM locations ORDER BY name")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch locations"})
		return
	}
	defer rows.Close()

	var locations []models.Location
	for rows.Next() {
		var l models.Location
		err := rows.Scan(&l.ID, &l.Name, &l.Code, &l.Description)
		if err != nil {
			continue
		}
		locations = append(locations, l)
	}

	c.JSON(http.StatusOK, gin.H{"data": locations})
}