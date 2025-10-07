package services

import (
	"database/sql"
	"time"
)

type InventoryService struct {
	DB *sql.DB
}

func NewInventoryService(db *sql.DB) *InventoryService {
	return &InventoryService{DB: db}
}

func (s *InventoryService) GetStockOpnames() ([]map[string]interface{}, error) {
	query := `SELECT id, product_id, system_stock, physical_stock, difference, status, notes, created_at FROM stock_opnames ORDER BY created_at DESC`
	
	rows, err := s.DB.Query(query)
	if err != nil {
		return []map[string]interface{}{}, nil
	}
	defer rows.Close()

	var results []map[string]interface{}
	for rows.Next() {
		var id, productID, systemStock, physicalStock, difference int
		var status, notes string
		var createdAt time.Time

		rows.Scan(&id, &productID, &systemStock, &physicalStock, &difference, &status, &notes, &createdAt)
		
		results = append(results, map[string]interface{}{
			"id":             id,
			"product_id":     productID,
			"system_stock":   systemStock,
			"physical_stock": physicalStock,
			"difference":     difference,
			"status":         status,
			"notes":          notes,
			"created_at":     createdAt.Format("2006-01-02"),
		})
	}

	return results, nil
}

func (s *InventoryService) GetProducts() ([]map[string]interface{}, error) {
	query := `SELECT id, name, sku, price FROM warehouse_product ORDER BY name`
	
	rows, err := s.DB.Query(query)
	if err != nil {
		return []map[string]interface{}{}, nil
	}
	defer rows.Close()

	var results []map[string]interface{}
	for rows.Next() {
		var id int
		var name, sku string
		var price float64

		rows.Scan(&id, &name, &sku, &price)
		
		results = append(results, map[string]interface{}{
			"id":    id,
			"name":  name,
			"sku":   sku,
			"price": price,
		})
	}

	return results, nil
}