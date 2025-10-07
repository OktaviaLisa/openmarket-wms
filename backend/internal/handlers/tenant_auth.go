package handlers

import (
	"encoding/json"
	"net/http"
	"wms-backend/internal/database"
	"golang.org/x/crypto/bcrypt"
	"fmt"
	"time"
)

type TenantRegisterRequest struct {
	Username    string `json:"username"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	FirstName   string `json:"first_name"`
	LastName    string `json:"last_name"`
	CompanyName string `json:"company_name"`
}

type TenantLoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func TenantRegister(w http.ResponseWriter, r *http.Request) {
	var req TenantRegisterRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	if req.Username == "" || req.Password == "" || req.Email == "" || req.CompanyName == "" {
		http.Error(w, "Username, password, email, and company name are required", http.StatusBadRequest)
		return
	}

	// Check if username exists
	var count int
	err := database.DB.QueryRow("SELECT COUNT(*) FROM auth_user WHERE username = $1", req.Username).Scan(&count)
	if err != nil || count > 0 {
		http.Error(w, "Username already exists", http.StatusConflict)
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		http.Error(w, "Error hashing password", http.StatusInternalServerError)
		return
	}

	// Insert tenant user
	var userID int
	err = database.DB.QueryRow(`
		INSERT INTO auth_user (username, email, password, first_name, last_name, user_type, company_name, roles, is_staff, is_superuser, is_active, date_joined) 
		VALUES ($1, $2, $3, $4, $5, 'tenant', $6, 'tenant', false, false, true, NOW()) RETURNING id
	`, req.Username, req.Email, string(hashedPassword), req.FirstName, req.LastName, req.CompanyName).Scan(&userID)

	if err != nil {
		http.Error(w, "Error creating user: "+err.Error(), http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"message": "Tenant registered successfully",
		"user_id": userID,
		"user_type": "tenant",
		"company_name": req.CompanyName,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func TenantLogin(w http.ResponseWriter, r *http.Request) {
	var req TenantLoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	if req.Username == "" || req.Password == "" {
		http.Error(w, "Username and password are required", http.StatusBadRequest)
		return
	}

	// Get user from database
	var userID int
	var hashedPassword, userType, companyName, firstName, lastName string
	err := database.DB.QueryRow(`
		SELECT id, password, user_type, company_name, first_name, last_name 
		FROM auth_user 
		WHERE username = $1 AND user_type = 'tenant' AND is_active = true
	`, req.Username).Scan(&userID, &hashedPassword, &userType, &companyName, &firstName, &lastName)

	if err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Check password
	if err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(req.Password)); err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Generate token
	token := fmt.Sprintf("tenant_%d_%d", userID, time.Now().Unix())

	response := map[string]interface{}{
		"access": token,
		"refresh": token,
		"user": map[string]interface{}{
			"id": userID,
			"username": req.Username,
			"user_type": userType,
			"company_name": companyName,
			"first_name": firstName,
			"last_name": lastName,
		},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}