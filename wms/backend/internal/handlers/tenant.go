package handlers

import (
	"encoding/json"
	"net/http"
	"strings"
	"wms-backend/internal/database"
)

// Inbound Requests
func GetInboundRequests(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query(`
		SELECT ir.id, ir.product_id, p.name as product_name, ir.quantity, 
		       ir.supplier, ir.status, ir.notes, ir.created_at
		FROM inbound_requests ir
		JOIN warehouse_product p ON ir.product_id = p.id
		ORDER BY ir.created_at DESC
	`)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var requests []map[string]interface{}
	for rows.Next() {
		var req map[string]interface{} = make(map[string]interface{})
		var id, productId, quantity int
		var productName, supplier, status, notes, createdAt string
		
		rows.Scan(&id, &productId, &productName, &quantity, &supplier, &status, &notes, &createdAt)
		
		req["id"] = id
		req["product_id"] = productId
		req["product_name"] = productName
		req["quantity"] = quantity
		req["supplier"] = supplier
		req["status"] = status
		req["notes"] = notes
		req["created_at"] = createdAt
		
		requests = append(requests, req)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(requests)
}

func CreateInboundRequest(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ProductID int    `json:"product_id"`
		Quantity  int    `json:"quantity"`
		Supplier  string `json:"supplier"`
		Notes     string `json:"notes"`
	}
	
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	var id int
	err := database.DB.QueryRow(`
		INSERT INTO inbound_requests (product_id, quantity, supplier, status, notes, created_at)
		VALUES ($1, $2, $3, 'pending', $4, NOW()) RETURNING id
	`, req.ProductID, req.Quantity, req.Supplier, req.Notes).Scan(&id)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"id":      id,
		"message": "Inbound request created successfully",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

// Outbound Requests
func GetOutboundRequests(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query(`
		SELECT or.id, or.product_id, p.name as product_name, or.quantity, 
		       or.destination, or.status, or.notes, or.created_at
		FROM outbound_requests or
		JOIN warehouse_product p ON or.product_id = p.id
		ORDER BY or.created_at DESC
	`)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var requests []map[string]interface{}
	for rows.Next() {
		var req map[string]interface{} = make(map[string]interface{})
		var id, productId, quantity int
		var productName, destination, status, notes, createdAt string
		
		rows.Scan(&id, &productId, &productName, &quantity, &destination, &status, &notes, &createdAt)
		
		req["id"] = id
		req["product_id"] = productId
		req["product_name"] = productName
		req["quantity"] = quantity
		req["destination"] = destination
		req["status"] = status
		req["notes"] = notes
		req["created_at"] = createdAt
		
		requests = append(requests, req)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(requests)
}

func CreateOutboundRequest(w http.ResponseWriter, r *http.Request) {
	var req struct {
		ProductID   int    `json:"product_id"`
		Quantity    int    `json:"quantity"`
		Destination string `json:"destination"`
		Notes       string `json:"notes"`
	}
	
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	var id int
	err := database.DB.QueryRow(`
		INSERT INTO outbound_requests (product_id, quantity, destination, status, notes, created_at)
		VALUES ($1, $2, $3, 'pending', $4, NOW()) RETURNING id
	`, req.ProductID, req.Quantity, req.Destination, req.Notes).Scan(&id)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"id":      id,
		"message": "Outbound request created successfully",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

// Orders
func GetOrders(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query(`
		SELECT id, order_number, customer, status, total_amount, created_at
		FROM orders ORDER BY created_at DESC
	`)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var orders []map[string]interface{}
	for rows.Next() {
		var order map[string]interface{} = make(map[string]interface{})
		var id int
		var orderNumber, customer, status, createdAt string
		var totalAmount float64
		
		rows.Scan(&id, &orderNumber, &customer, &status, &totalAmount, &createdAt)
		
		order["id"] = id
		order["order_number"] = orderNumber
		order["customer"] = customer
		order["status"] = status
		order["total_amount"] = totalAmount
		order["created_at"] = createdAt
		
		orders = append(orders, order)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(orders)
}

// Reports
func GetStockReport(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query(`
		SELECT p.id, p.name, p.sku, COALESCE(i.quantity, 0) as stock_level,
		       COALESCE(i.min_stock, 0) as min_stock
		FROM warehouse_product p
		LEFT JOIN inventory i ON p.id = i.product_id
		ORDER BY p.name
	`)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var report []map[string]interface{}
	for rows.Next() {
		var item map[string]interface{} = make(map[string]interface{})
		var id, stockLevel, minStock int
		var name, sku string
		
		rows.Scan(&id, &name, &sku, &stockLevel, &minStock)
		
		item["id"] = id
		item["name"] = name
		item["sku"] = sku
		item["stock_level"] = stockLevel
		item["min_stock"] = minStock
		item["status"] = "normal"
		if stockLevel <= minStock {
			item["status"] = "low"
		}
		
		report = append(report, item)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(report)
}

func GetTransactionReport(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query(`
		SELECT sm.id, p.name as product_name, sm.movement_type, sm.quantity,
		       sm.reference, sm.created_at
		FROM stock_movements sm
		JOIN warehouse_product p ON sm.product_id = p.id
		ORDER BY sm.created_at DESC
		LIMIT 100
	`)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var transactions []map[string]interface{}
	for rows.Next() {
		var txn map[string]interface{} = make(map[string]interface{})
		var id, quantity int
		var productName, movementType, reference, createdAt string
		
		rows.Scan(&id, &productName, &movementType, &quantity, &reference, &createdAt)
		
		txn["id"] = id
		txn["product_name"] = productName
		txn["movement_type"] = movementType
		txn["quantity"] = quantity
		txn["reference"] = reference
		txn["created_at"] = createdAt
		
		transactions = append(transactions, txn)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(transactions)
}

// Route handlers
func InboundRequestsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetInboundRequests(w, r)
	case "POST":
		CreateInboundRequest(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func OutboundRequestsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetOutboundRequests(w, r)
	case "POST":
		CreateOutboundRequest(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func ReportsHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/api/reports/")
	
	switch path {
	case "stock":
		GetStockReport(w, r)
	case "transactions":
		GetTransactionReport(w, r)
	default:
		http.Error(w, "Report not found", http.StatusNotFound)
	}
}