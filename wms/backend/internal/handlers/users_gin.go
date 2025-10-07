package handlers

import (
	"net/http"
	"wms-backend/internal/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

func (h *Handler) GetUsersGin(c *gin.Context) {
	rows, err := h.DB.Query("SELECT id, username, email, is_staff, role, first_name, last_name, is_active FROM auth_user ORDER BY id")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Username, &user.Email, &user.IsStaff, &user.Role, &user.FirstName, &user.LastName, &user.IsActive)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		users = append(users, user)
	}

	c.JSON(http.StatusOK, users)
}

func (h *Handler) CreateUserGin(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	if req.Username == "" || req.Email == "" || req.Password == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "All fields are required"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not hash password"})
		return
	}

	var userID int
	err = h.DB.QueryRow(
		"INSERT INTO auth_user (username, email, password, first_name, last_name, role, is_staff, is_superuser, is_active, date_joined) VALUES ($1, $2, $3, $4, $5, $6, false, false, true, NOW()) RETURNING id",
		req.Username, req.Email, string(hashedPassword), req.FirstName, req.LastName, req.Role,
	).Scan(&userID)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Username or email already exists"})
		return
	}

	user := models.User{
		ID:        userID,
		Username:  req.Username,
		Email:     req.Email,
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Role:      req.Role,
		IsStaff:   false,
		IsActive:  true,
	}

	c.JSON(http.StatusCreated, user)
}