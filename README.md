# Warehouse Management System

Project warehouse management system dengan Django backend, Flutter frontend untuk client/vendor, dan React admin dashboard.

## Struktur Project

```
wms-project/
├── backend/               # Go API
│   ├── models/            # Data models
│   ├── handlers/          # API handlers
│   ├── database/          # Database connection
│   ├── go.mod            # Go dependencies
│   └── Dockerfile        # Docker config untuk backend
├── frontend/              # Flutter app (Client/Vendor + Admin)
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── services/      # API services
│   │   ├── providers/     # State management
│   │   └── screens/       # UI screens (termasuk admin)
│   ├── pubspec.yaml       # Flutter dependencies
│   └── Dockerfile         # Docker config untuk frontend
└── docker-compose.yml     # Docker compose configuration
```

## Cara Menjalankan

### Quick Start (Recommended)

1. Pastikan Docker, Docker Compose, dan Flutter terinstall
2. Setup Flutter dependencies:
```bash
./setup-flutter.sh
```

3. Jalankan aplikasi:
```bash
./start-flutter.sh
```

4. Akses aplikasi:
   - **Flutter Frontend (Unified App)**: http://localhost:3000
   - **Backend API**: http://localhost:8000
   - **Database Admin (PgAdmin)**: http://localhost:5050
     - Email: admin@admin.com
     - Password: admin

### Default Admin Credentials
- **Username**: admin
- **Password**: admin123

### Development Commands

Gunakan script helper untuk development:
```bash
# Start semua services
./dev.sh start

# Stop semua services
./dev.sh stop

# Restart services
./dev.sh restart

# Lihat logs
./dev.sh logs

# Clean up
./dev.sh clean

# Flutter commands
./dev.sh flutter get
./dev.sh flutter clean
./dev.sh flutter analyze

# Backend commands
./dev.sh backend migrate
./dev.sh backend createsuperuser
```

### Manual Setup (Development)

#### Backend (Go)
```bash
cd backend-go
go mod tidy
go run main.go
```



#### Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run -d web-server --web-port 3000
```

## Dashboards

### Flutter Unified Dashboard (Port 3000)
- **Target Users**: System Administrators, Clients, dan Vendors
- **Admin Features**:
  - User management
  - System analytics and reports
  - Product management
  - Inventory overview
  - Advanced charts and statistics
- **Warehouse Features**:
  - Warehouse operations
  - Stock management
  - Reception and dispatch
  - Quality control
  - Stock opname

## API Endpoints

### Authentication
- `POST /api/auth/login/` - Login
- `POST /api/auth/register/` - Register
- `POST /api/auth/refresh/` - Refresh token

### Core Endpoints
- `GET /api/products/` - Daftar semua produk
- `POST /api/products/` - Tambah produk baru
- `GET /api/categories/` - Daftar kategori
- `GET /api/inventory/` - Daftar inventory
- `GET /api/stock-movements/` - Riwayat pergerakan stok
- `GET /api/users/` - Daftar users (admin only)

## Features

### Core WMS Features
- ✅ Product management
- ✅ Inventory tracking & monitoring
- ✅ Stock movements
- ✅ Category management
- ✅ User management
- ✅ Role-based access control

### Warehouse Operations
- ✅ Reception (Penerimaan barang)
- ✅ Dispatch (Pengeluaran barang)
- ✅ Returns (Pengembalian barang)
- ✅ Stock Opname (Pencatatan stok berkala)

### Quality Control
- ✅ Incoming goods inspection
- ✅ Outgoing goods inspection
- ✅ Return goods inspection

### Technical Features
- ✅ REST API with Go Gin Framework
- ✅ JWT Authentication
- ✅ Docker containerization
- ✅ Flutter unified interface (Admin + Warehouse)
- ✅ PostgreSQL database
- ✅ Role-based dashboards
- ✅ Charts and analytics with FL Chart
- ✅ Responsive design

## Tech Stack

- **Backend**: Go + Gin Framework + PostgreSQL
- **Frontend**: Flutter Web (Unified Admin + Warehouse)
- **Charts**: FL Chart
- **Authentication**: JWT (JSON Web Tokens)
- **Containerization**: Docker + Docker Compose
- **Database**: PostgreSQL

## User Roles

### Admin
- Access to Flutter Admin Dashboard
- Full system management capabilities
- User management
- System analytics
- Product management
- Inventory oversight
- Reports and analytics

### Client/Vendor
- Access to Flutter Warehouse Dashboard
- Warehouse operations
- Limited to operational features

## Architecture

```
          ┌─────────────────┐
          │  Flutter Web    │
          │  Unified App    │
          │  (Port 3000)    │
          └─────────┬───────┘
                    │
          ┌─────────────────┐
          │  Go API         │
          │  (Port 8000)    │
          └─────────┬───────┘
                    │
          ┌─────────────────┐
          │  PostgreSQL     │
          │  Database       │
          └─────────────────┘
```

## Development Notes

- Flutter unified app runs on port 3000
- Backend API runs on port 8000
- All services are connected via Docker network
- JWT tokens are used for authentication
- CORS is configured for Flutter web app
- Role-based routing within Flutter app
- Admin and warehouse features in single application