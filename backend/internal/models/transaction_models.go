package models

import "time"

type Supplier struct {
	ID            int       `json:"id" db:"id"`
	Name          string    `json:"name" db:"name"`
	ContactPerson string    `json:"contact_person" db:"contact_person"`
	Phone         string    `json:"phone" db:"phone"`
	Email         string    `json:"email" db:"email"`
	Address       string    `json:"address" db:"address"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}

type Customer struct {
	ID            int       `json:"id" db:"id"`
	Name          string    `json:"name" db:"name"`
	ContactPerson string    `json:"contact_person" db:"contact_person"`
	Phone         string    `json:"phone" db:"phone"`
	Email         string    `json:"email" db:"email"`
	Address       string    `json:"address" db:"address"`
	CreatedAt     time.Time `json:"created_at" db:"created_at"`
}

type Unit struct {
	ID        int       `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Symbol    string    `json:"symbol" db:"symbol"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

type Location struct {
	ID          int       `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	Code        string    `json:"code" db:"code"`
	Description string    `json:"description" db:"description"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
}

type Receiving struct {
	ID             int       `json:"id" db:"id"`
	DocumentNumber string    `json:"document_number" db:"document_number"`
	ReceiveDate    time.Time `json:"receive_date" db:"receive_date"`
	SupplierID     int       `json:"supplier_id" db:"supplier_id"`
	ProductID      int       `json:"product_id" db:"product_id"`
	Quantity       int       `json:"quantity" db:"quantity"`
	UnitID         int       `json:"unit_id" db:"unit_id"`
	LocationID     int       `json:"location_id" db:"location_id"`
	Remarks        string    `json:"remarks" db:"remarks"`
	CreatedBy      int       `json:"created_by" db:"created_by"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	
	// Relations
	SupplierName string `json:"supplier_name,omitempty" db:"supplier_name"`
	ProductName  string `json:"product_name,omitempty" db:"product_name"`
	UnitSymbol   string `json:"unit_symbol,omitempty" db:"unit_symbol"`
	LocationName string `json:"location_name,omitempty" db:"location_name"`
}

type Issuing struct {
	ID             int       `json:"id" db:"id"`
	DocumentNumber string    `json:"document_number" db:"document_number"`
	IssueDate      time.Time `json:"issue_date" db:"issue_date"`
	CustomerID     int       `json:"customer_id" db:"customer_id"`
	ProductID      int       `json:"product_id" db:"product_id"`
	Quantity       int       `json:"quantity" db:"quantity"`
	UnitID         int       `json:"unit_id" db:"unit_id"`
	LocationID     int       `json:"location_id" db:"location_id"`
	Remarks        string    `json:"remarks" db:"remarks"`
	CreatedBy      int       `json:"created_by" db:"created_by"`
	CreatedAt      time.Time `json:"created_at" db:"created_at"`
	
	// Relations
	CustomerName string `json:"customer_name,omitempty" db:"customer_name"`
	ProductName  string `json:"product_name,omitempty" db:"product_name"`
	UnitSymbol   string `json:"unit_symbol,omitempty" db:"unit_symbol"`
	LocationName string `json:"location_name,omitempty" db:"location_name"`
}

type ReceivingRequest struct {
	ReceiveDate string `json:"receive_date" binding:"required"`
	SupplierID  int    `json:"supplier_id" binding:"required"`
	ProductID   int    `json:"product_id" binding:"required"`
	Quantity    int    `json:"quantity" binding:"required,min=1"`
	UnitID      int    `json:"unit_id" binding:"required"`
	LocationID  int    `json:"location_id" binding:"required"`
	Remarks     string `json:"remarks"`
}

type IssuingRequest struct {
	IssueDate  string `json:"issue_date" binding:"required"`
	CustomerID int    `json:"customer_id" binding:"required"`
	ProductID  int    `json:"product_id" binding:"required"`
	Quantity   int    `json:"quantity" binding:"required,min=1"`
	UnitID     int    `json:"unit_id" binding:"required"`
	LocationID int    `json:"location_id" binding:"required"`
	Remarks    string `json:"remarks"`
}