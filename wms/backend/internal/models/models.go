package models

type User struct {
	ID        int      `json:"id"`
	Username  string   `json:"username"`
	Email     string   `json:"email"`
	IsStaff   bool     `json:"is_staff"`
	Role      string   `json:"role"`
	Roles     []string `json:"roles"`
	FirstName string   `json:"first_name"`
	LastName  string   `json:"last_name"`
	IsActive  bool     `json:"is_active"`
}

type Product struct {
	ID          int     `json:"id"`
	Name        string  `json:"name"`
	SKU         string  `json:"sku"`
	CategoryID  int     `json:"category_id"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Stock       int     `json:"stock"`
	CreatedAt   string  `json:"created_at"`
}

type Category struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	CreatedAt   string `json:"created_at"`
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type RegisterRequest struct {
	Username  string `json:"username"`
	Email     string `json:"email"`
	Password  string `json:"password"`
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Role      string `json:"role"`
}

type CreateUserRequest struct {
	Username  string   `json:"username"`
	Email     string   `json:"email"`
	Password  string   `json:"password"`
	FirstName string   `json:"first_name"`
	LastName  string   `json:"last_name"`
	Role      string   `json:"role"`
	Roles     []string `json:"roles"`
}

type TokenResponse struct {
	Access  string `json:"access"`
	Refresh string `json:"refresh"`
}

// Goods Receipt Models
type PenerimaanBarang struct {
	ID         int    `json:"id"`
	NoDokumen  string `json:"no_dokumen"`
	Tanggal    string `json:"tanggal"`
	Supplier   string `json:"supplier"`
	NoPO       string `json:"no_po"`
	Status     string `json:"status"`
	CreatedAt  string `json:"created_at"`
	UpdatedAt  string `json:"updated_at"`
}

type DetailPenerimaan struct {
	ID           int    `json:"id"`
	PenerimaanID int    `json:"penerimaan_id"`
	SKU          string `json:"sku"`
	NamaBarang   string `json:"nama_barang"`
	Jumlah       int    `json:"jumlah"`
	Batch        string `json:"batch"`
	ExpiredDate  string `json:"expired_date"`
	Satuan       string `json:"satuan"`
	CreatedAt    string `json:"created_at"`
}

type PemeriksaanKualitas struct {
	ID                 int    `json:"id"`
	DetailPenerimaanID int    `json:"detail_penerimaan_id"`
	Status             string `json:"status"`
	Keterangan         string `json:"keterangan"`
	CreatedAt          string `json:"created_at"`
}

type CreatePenerimaanRequest struct {
	NoDokumen string `json:"no_dokumen"`
	Tanggal   string `json:"tanggal"`
	Supplier  string `json:"supplier"`
	NoPO      string `json:"no_po"`
}

type CreateDetailPenerimaanRequest struct {
	SKU         string `json:"sku"`
	NamaBarang  string `json:"nama_barang"`
	Jumlah      int    `json:"jumlah"`
	Batch       string `json:"batch"`
	ExpiredDate string `json:"expired_date"`
	Satuan      string `json:"satuan"`
}

type CreatePemeriksaanRequest struct {
	Status     string `json:"status"`
	Keterangan string `json:"keterangan"`
}