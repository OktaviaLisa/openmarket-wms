package models

import (
	"time"
)

// StockOpname - Pencatatan stok berkala
type StockOpname struct {
	ID          uint      `json:"id" gorm:"primaryKey"`
	ProductID   uint      `json:"product_id"`
	Product     Product   `json:"product" gorm:"foreignKey:ProductID"`
	SystemStock int       `json:"system_stock"`
	PhysicalStock int     `json:"physical_stock"`
	Difference  int       `json:"difference"`
	Status      string    `json:"status"` // PENDING, APPROVED, REJECTED
	Notes       string    `json:"notes"`
	CreatedBy   uint      `json:"created_by"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// StockMovement - Pergerakan stok
type StockMovement struct {
	ID            uint      `json:"id" gorm:"primaryKey"`
	ProductID     uint      `json:"product_id"`
	Product       Product   `json:"product" gorm:"foreignKey:ProductID"`
	MovementType  string    `json:"movement_type"` // IN, OUT, TRANSFER
	Quantity      int       `json:"quantity"`
	FromLocation  string    `json:"from_location"`
	ToLocation    string    `json:"to_location"`
	ReferenceType string    `json:"reference_type"` // RECEPTION, DISPATCH, RETURN, OPNAME
	ReferenceID   uint      `json:"reference_id"`
	Notes         string    `json:"notes"`
	CreatedBy     uint      `json:"created_by"`
	CreatedAt     time.Time `json:"created_at"`
}

// Reception - Penerimaan barang
type Reception struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	ProductID  uint      `json:"product_id"`
	Product    Product   `json:"product" gorm:"foreignKey:ProductID"`
	Quantity   int       `json:"quantity"`
	Supplier   string    `json:"supplier"`
	Status     string    `json:"status"` // PENDING, RECEIVED, QUALITY_CHECK, COMPLETED
	Notes      string    `json:"notes"`
	CreatedBy  uint      `json:"created_by"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// Dispatch - Pengeluaran barang
type Dispatch struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	ProductID  uint      `json:"product_id"`
	Product    Product   `json:"product" gorm:"foreignKey:ProductID"`
	Quantity   int       `json:"quantity"`
	Customer   string    `json:"customer"`
	Status     string    `json:"status"` // PENDING, PICKED, SHIPPED, DELIVERED
	Notes      string    `json:"notes"`
	CreatedBy  uint      `json:"created_by"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// Return - Pengembalian barang
type Return struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	ProductID  uint      `json:"product_id"`
	Product    Product   `json:"product" gorm:"foreignKey:ProductID"`
	Quantity   int       `json:"quantity"`
	ReturnType string    `json:"return_type"` // CUSTOMER, SUPPLIER
	Reason     string    `json:"reason"`
	Status     string    `json:"status"` // PENDING, APPROVED, REJECTED
	Notes      string    `json:"notes"`
	CreatedBy  uint      `json:"created_by"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// QualityCheck - Pemeriksaan kualitas
type QualityCheck struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	ReceptionID int       `json:"reception_id"`
	ProductName string    `json:"product_name"`
	Quantity    int       `json:"quantity"`
	Status      string    `json:"status"`
	Notes       string    `json:"notes"`
	CheckedAt   time.Time `json:"checked_at"`
}

