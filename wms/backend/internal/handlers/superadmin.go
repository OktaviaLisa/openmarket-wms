package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"wms-backend/internal/database"
	"golang.org/x/crypto/bcrypt"
)

type CreateWarehouseAdminRequest struct {
	Username    string `json:"username"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	WarehouseName string `json:"warehouse_name"`
	Location    string `json:"location"`
}

type CreateTenantAdminRequest struct {
	Username    string `json:"username"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	CompanyName string `json:"company_name"`
}

// Create Warehouse Admin
func CreateWarehouseAdmin(w http.ResponseWriter, r *http.Request) {
	var req CreateWarehouseAdminRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Create warehouse first
	var warehouseID int
	err := database.DB.QueryRow(`
		INSERT INTO warehouses (name, location, created_at)
		VALUES ($1, $2, NOW()) RETURNING id
	`, req.WarehouseName, req.Location).Scan(&warehouseID)

	if err != nil {
		http.Error(w, "Error creating warehouse", http.StatusInternalServerError)
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Error hashing password", http.StatusInternalServerError)
		return
	}

	// Create warehouse admin user
	var userID int
	err = database.DB.QueryRow(`
		INSERT INTO auth_user (username, email, password, first_name, last_name, user_type, warehouse_id, roles, is_staff, is_superuser, is_active, date_joined)
		VALUES ($1, $2, $3, $4, $5, 'warehouse_admin', $6, 'admin', true, false, true, NOW()) RETURNING id
	`, req.Username, req.Email, string(hashedPassword), req.FirstName, req.LastName, warehouseID).Scan(&userID)

	if err != nil {
		http.Error(w, "Error creating user", http.StatusInternalServerError)
		return
	}

	// Update warehouse manager_id
	database.DB.Exec("UPDATE warehouses SET manager_id = $1 WHERE id = $2", userID, warehouseID)

	response := map[string]interface{}{
		"message": "Warehouse admin created successfully",
		"user_id": userID,
		"warehouse_id": warehouseID,
		"warehouse_name": req.WarehouseName,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

// Create Tenant Admin
func CreateTenantAdmin(w http.ResponseWriter, r *http.Request) {
	var req CreateTenantAdminRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Error hashing password", http.StatusInternalServerError)
		return
	}

	// Create tenant admin user
	var userID int
	err = database.DB.QueryRow(`
		INSERT INTO auth_user (username, email, password, first_name, last_name, user_type, company_name, roles, is_staff, is_superuser, is_active, date_joined)
		VALUES ($1, $2, $3, $4, $5, 'tenant_admin', $6, 'admin', true, false, true, NOW()) RETURNING id
	`, req.Username, req.Email, string(hashedPassword), req.FirstName, req.LastName, req.CompanyName).Scan(&userID)

	if err != nil {
		http.Error(w, "Error creating user", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"message": "Tenant admin created successfully",
		"user_id": userID,
		"company_name": req.CompanyName,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

// Get All Admins
func GetAllAdmins(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query(`
		SELECT u.id, u.username, u.email, u.first_name, u.last_name, u.user_type, 
		       u.company_name, u.warehouse_id, w.name as warehouse_name, u.is_active
		FROM auth_user u
		LEFT JOIN warehouses w ON u.warehouse_id = w.id
		WHERE u.user_type IN ('warehouse_admin', 'tenant_admin')
		ORDER BY u.user_type, u.username
	`)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var admins []map[string]interface{}
	for rows.Next() {
		var admin map[string]interface{} = make(map[string]interface{})
		var id int
		var username, email, firstName, lastName, userType, companyName string
		var isActive bool
		var warehouseIDPtr *int
		var warehouseNamePtr *string

		rows.Scan(&id, &username, &email, &firstName, &lastName, &userType, &companyName, &warehouseIDPtr, &warehouseNamePtr, &isActive)

		admin["id"] = id
		admin["username"] = username
		admin["email"] = email
		admin["first_name"] = firstName
		admin["last_name"] = lastName
		admin["user_type"] = userType
		admin["company_name"] = companyName
		admin["is_active"] = isActive

		if warehouseIDPtr != nil {
			admin["warehouse_id"] = *warehouseIDPtr
		}
		if warehouseNamePtr != nil {
			admin["warehouse_name"] = *warehouseNamePtr
		}

		admins = append(admins, admin)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(admins)
}

// Update Admin
func UpdateAdmin(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/api/superadmin/admins/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	var req map[string]interface{}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Build update query dynamically
	setParts := []string{}
	args := []interface{}{}
	argIndex := 1

	if email, ok := req["email"]; ok {
		setParts = append(setParts, "email = $"+strconv.Itoa(argIndex))
		args = append(args, email)
		argIndex++
	}
	if firstName, ok := req["first_name"]; ok {
		setParts = append(setParts, "first_name = $"+strconv.Itoa(argIndex))
		args = append(args, firstName)
		argIndex++
	}
	if lastName, ok := req["last_name"]; ok {
		setParts = append(setParts, "last_name = $"+strconv.Itoa(argIndex))
		args = append(args, lastName)
		argIndex++
	}
	if isActive, ok := req["is_active"]; ok {
		setParts = append(setParts, "is_active = $"+strconv.Itoa(argIndex))
		args = append(args, isActive)
		argIndex++
	}

	if len(setParts) == 0 {
		http.Error(w, "No fields to update", http.StatusBadRequest)
		return
	}

	query := "UPDATE auth_user SET " + strings.Join(setParts, ", ") + " WHERE id = $" + strconv.Itoa(argIndex)
	args = append(args, id)

	_, err = database.DB.Exec(query, args...)
	if err != nil {
		http.Error(w, "Error updating admin", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"message": "Admin updated successfully",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// Delete Admin
func DeleteAdmin(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/api/superadmin/admins/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid ID", http.StatusBadRequest)
		return
	}

	_, err = database.DB.Exec("UPDATE auth_user SET is_active = false WHERE id = $1", id)
	if err != nil {
		http.Error(w, "Error deleting admin", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"message": "Admin deleted successfully",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// Route handlers
func SuperAdminHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/api/superadmin/")
	
	switch {
	case path == "warehouse-admins" && r.Method == "POST":
		CreateWarehouseAdmin(w, r)
	case path == "tenant-admins" && r.Method == "POST":
		CreateTenantAdmin(w, r)
	case path == "admins" && r.Method == "GET":
		GetAllAdmins(w, r)
	case strings.HasPrefix(path, "admins/") && r.Method == "PUT":
		UpdateAdmin(w, r)
	case strings.HasPrefix(path, "admins/") && r.Method == "DELETE":
		DeleteAdmin(w, r)
	default:
		http.Error(w, "Not found", http.StatusNotFound)
	}
}