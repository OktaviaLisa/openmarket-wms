package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"wms-backend/internal/models"
)

func (h *Handler) CreatePenerimaan(c *gin.Context) {
	var req models.CreatePenerimaanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := `INSERT INTO penerimaan_barang (no_dokumen, tanggal, supplier, no_po) 
			  VALUES ($1, $2, $3, $4) RETURNING id, created_at, updated_at`
	
	var penerimaan models.PenerimaanBarang
	err := h.DB.QueryRow(query, req.NoDokumen, req.Tanggal, req.Supplier, req.NoPO).
		Scan(&penerimaan.ID, &penerimaan.CreatedAt, &penerimaan.UpdatedAt)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	penerimaan.NoDokumen = req.NoDokumen
	penerimaan.Tanggal = req.Tanggal
	penerimaan.Supplier = req.Supplier
	penerimaan.NoPO = req.NoPO
	penerimaan.Status = "draft"

	c.JSON(http.StatusCreated, penerimaan)
}

func (h *Handler) GetPenerimaan(c *gin.Context) {
	query := `SELECT id, no_dokumen, tanggal, supplier, no_po, status, created_at, updated_at 
			  FROM penerimaan_barang ORDER BY created_at DESC`
	
	rows, err := h.DB.Query(query)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var penerimaanList []models.PenerimaanBarang
	for rows.Next() {
		var p models.PenerimaanBarang
		err := rows.Scan(&p.ID, &p.NoDokumen, &p.Tanggal, &p.Supplier, &p.NoPO, &p.Status, &p.CreatedAt, &p.UpdatedAt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		penerimaanList = append(penerimaanList, p)
	}

	c.JSON(http.StatusOK, penerimaanList)
}

func (h *Handler) AddDetailPenerimaan(c *gin.Context) {
	id := c.Param("id")
	penerimaanID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var req models.CreateDetailPenerimaanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := `INSERT INTO detail_penerimaan (penerimaan_id, sku, nama_barang, jumlah, batch, expired_date, satuan) 
			  VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, created_at`
	
	var detail models.DetailPenerimaan
	err = h.DB.QueryRow(query, penerimaanID, req.SKU, req.NamaBarang, req.Jumlah, req.Batch, req.ExpiredDate, req.Satuan).
		Scan(&detail.ID, &detail.CreatedAt)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	detail.PenerimaanID = penerimaanID
	detail.SKU = req.SKU
	detail.NamaBarang = req.NamaBarang
	detail.Jumlah = req.Jumlah
	detail.Batch = req.Batch
	detail.ExpiredDate = req.ExpiredDate
	detail.Satuan = req.Satuan

	c.JSON(http.StatusCreated, detail)
}

func (h *Handler) GetDetailPenerimaan(c *gin.Context) {
	id := c.Param("id")
	penerimaanID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	query := `SELECT id, penerimaan_id, sku, nama_barang, jumlah, batch, expired_date, satuan, created_at 
			  FROM detail_penerimaan WHERE penerimaan_id = $1`
	
	rows, err := h.DB.Query(query, penerimaanID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var details []models.DetailPenerimaan
	for rows.Next() {
		var d models.DetailPenerimaan
		err := rows.Scan(&d.ID, &d.PenerimaanID, &d.SKU, &d.NamaBarang, &d.Jumlah, &d.Batch, &d.ExpiredDate, &d.Satuan, &d.CreatedAt)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		details = append(details, d)
	}

	c.JSON(http.StatusOK, details)
}

func (h *Handler) CreatePemeriksaanKualitas(c *gin.Context) {
	detailID := c.Param("detailId")
	detailPenerimaanID, err := strconv.Atoi(detailID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid detail ID"})
		return
	}

	var req models.CreatePemeriksaanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := `INSERT INTO pemeriksaan_kualitas (detail_penerimaan_id, status, keterangan) 
			  VALUES ($1, $2, $3) RETURNING id, created_at`
	
	var pemeriksaan models.PemeriksaanKualitas
	err = h.DB.QueryRow(query, detailPenerimaanID, req.Status, req.Keterangan).
		Scan(&pemeriksaan.ID, &pemeriksaan.CreatedAt)
	
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	pemeriksaan.DetailPenerimaanID = detailPenerimaanID
	pemeriksaan.Status = req.Status
	pemeriksaan.Keterangan = req.Keterangan

	c.JSON(http.StatusCreated, pemeriksaan)
}

func (h *Handler) CompletePenerimaan(c *gin.Context) {
	id := c.Param("id")
	penerimaanID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	query := `UPDATE penerimaan_barang SET status = 'completed', updated_at = CURRENT_TIMESTAMP WHERE id = $1`
	
	_, err = h.DB.Exec(query, penerimaanID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Penerimaan completed successfully"})
}