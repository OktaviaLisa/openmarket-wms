package handlers

import (
	"encoding/json"
	"net/http"
	"strings"
	"wms-backend/internal/database"
	"wms-backend/internal/models"
	"golang.org/x/crypto/bcrypt"
)

func GetUsers(w http.ResponseWriter, r *http.Request) {
	rows, err := database.DB.Query("SELECT id, username, email, is_staff, role, roles, first_name, last_name, is_active, user_type, company_name FROM auth_user ORDER BY username")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		var rolesStr, userType, companyName string
		rows.Scan(&user.ID, &user.Username, &user.Email, &user.IsStaff, &user.Role, &rolesStr, &user.FirstName, &user.LastName, &user.IsActive, &userType, &companyName)
		
		// Parse roles string to array
		if rolesStr != "" {
			user.Roles = strings.Split(rolesStr, ",")
		} else {
			user.Roles = []string{"user"}
		}
		
		users = append(users, user)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}

func CreateUser(w http.ResponseWriter, r *http.Request) {
	var req models.CreateUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid JSON"})
		return
	}

	// Validate roles
	validRoles := map[string]bool{
		"warehouse_management": true,
		"operator_gudang": true,
		"checker": true,
		"qc": true,
		"picker": true,
	}
	
	// Use roles array if provided, otherwise use single role
	roles := req.Roles
	if len(roles) == 0 && req.Role != "" {
		roles = []string{req.Role}
	}
	
	for _, role := range roles {
		if !validRoles[role] {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusBadRequest)
			json.NewEncoder(w).Encode(map[string]string{"error": "Invalid role: " + role})
			return
		}
	}
	
	rolesStr := strings.Join(roles, ",")
	primaryRole := roles[0]

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Could not hash password"})
		return
	}

	var userID int
	err = database.DB.QueryRow(
		"INSERT INTO auth_user (username, email, password, first_name, last_name, role, roles, is_staff, is_superuser, is_active, date_joined) VALUES ($1, $2, $3, $4, $5, $6, $7, false, false, true, NOW()) RETURNING id",
		req.Username, req.Email, string(hashedPassword), req.FirstName, req.LastName, primaryRole, rolesStr,
	).Scan(&userID)

	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Username or email already exists"})
		return
	}

	user := models.User{
		ID:        userID,
		Username:  req.Username,
		Email:     req.Email,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Role:      primaryRole,
		Roles:     roles,
		IsStaff:   false,
		IsActive:  true,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"user":    user,
		"message": "User created successfully",
	})
}

func UpdateUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Path[len("/api/users/"):]
	if userID == "" {
		http.Error(w, "User ID required", http.StatusBadRequest)
		return
	}

	var req models.CreateUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "Invalid JSON"})
		return
	}

	// Handle roles update
	roles := req.Roles
	if len(roles) == 0 && req.Role != "" {
		roles = []string{req.Role}
	}
	rolesStr := strings.Join(roles, ",")
	primaryRole := roles[0]
	
	_, err := database.DB.Exec(
		"UPDATE auth_user SET first_name = $1, last_name = $2, role = $3, roles = $4, is_active = $5 WHERE id = $6",
		req.FirstName, req.LastName, primaryRole, rolesStr, true, userID,
	)

	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Failed to update user"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "User updated successfully"})
}

func DeleteUser(w http.ResponseWriter, r *http.Request) {
	userID := r.URL.Path[len("/api/users/"):]
	if userID == "" {
		http.Error(w, "User ID required", http.StatusBadRequest)
		return
	}

	_, err := database.DB.Exec("UPDATE auth_user SET is_active = false WHERE id = $1", userID)
	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]string{"error": "Failed to deactivate user"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"message": "User deactivated successfully"})
}

func GetRoles(w http.ResponseWriter, r *http.Request) {
	roles := []map[string]string{
		{"value": "warehouse_management", "label": "Warehouse Management"},
		{"value": "operator_gudang", "label": "Operator Gudang"},
		{"value": "checker", "label": "Checker"},
		{"value": "qc", "label": "Quality Control (QC)"},
		{"value": "picker", "label": "Picker"},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(roles)
}

func UsersHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetUsers(w, r)
	case "POST":
		CreateUser(w, r)
	case "PUT":
		UpdateUser(w, r)
	case "DELETE":
		DeleteUser(w, r)
	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func EmptyResponse(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode([]interface{}{})
}