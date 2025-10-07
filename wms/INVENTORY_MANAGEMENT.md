# Inventory Management System

## Overview
Sistem manajemen inventory lengkap dengan 8 modul utama untuk mengelola operasional gudang.

## Struktur Menu Dashboard

### 1. Manajemen Inventory
- **Stock Opname** (`/stock-opname`) - Pencatatan stok berkala
- **Stock Movement** (`/stock-movement`) - Pemantauan pergerakan barang
- **Monitoring Inventory** (`/inventory-monitoring`) - Status real-time inventory

### 2. Operasional
- **Penerimaan** (`/reception`) - Barang masuk dari supplier
- **Pengeluaran** (`/dispatch`) - Barang keluar ke customer
- **Pengembalian** (`/returns`) - Return dari customer/supplier

### 3. Quality Control
- **Quality Control** (`/quality-control`) - Pemeriksaan barang masuk/keluar/retur

### 4. Pelaporan
- **Laporan** (`/inventory-reports`) - Semua jenis laporan inventory

## Database Schema

### Tables Created:
- `stock_opnames` - Data stock opname
- `stock_movements` - Riwayat pergerakan stok
- `receptions` - Data penerimaan barang
- `dispatches` - Data pengeluaran barang
- `returns` - Data pengembalian barang
- `quality_checks` - Data pemeriksaan kualitas

## API Endpoints

### Stock Opname
- `GET /api/stock-opnames` - List stock opname
- `POST /api/stock-opnames` - Create stock opname

### Stock Movement
- `GET /api/stock-movements` - List movements
- `POST /api/stock-movements` - Create movement

### Reception
- `GET /api/receptions` - List receptions
- `POST /api/receptions` - Create reception
- `PUT /api/receptions/:id/status` - Update status

### Dispatch
- `GET /api/dispatches` - List dispatches
- `POST /api/dispatches` - Create dispatch

### Returns
- `GET /api/returns` - List returns
- `POST /api/returns` - Create return

### Quality Control
- `GET /api/quality-checks` - List quality checks
- `POST /api/quality-checks` - Create quality check

### Monitoring
- `GET /api/inventory-monitoring` - Real-time inventory status

## Flutter Screens Created

1. `stock_opname_screen.dart` - Stock opname management
2. `stock_movement_screen.dart` - Stock movement tracking
3. `inventory_monitoring_screen.dart` - Real-time monitoring
4. `dispatch_screen.dart` - Outgoing goods management
5. `returns_screen.dart` - Returns management
6. `quality_control_screen.dart` - Quality inspection
7. `inventory_reports_screen.dart` - Comprehensive reports

## Features Implemented

### UI Features
- Form input dengan validasi
- Status chips dengan warna
- Real-time monitoring cards
- Charts untuk laporan
- Data tables untuk listing
- Search dan filter capabilities

### Backend Features
- CRUD operations untuk semua modul
- Status tracking
- Relationship antar tabel
- API endpoints lengkap
- Error handling

## Installation & Setup

1. Run database migration:
```sql
-- Execute inventory_schema.sql
```

2. Update backend dependencies:
```bash
cd backend
go mod tidy
```

3. Update Flutter dependencies:
```bash
cd frontend
flutter pub get
```

4. Run application:
```bash
./dev.sh start
```

## Usage

Akses dashboard di http://localhost:3000 dan pilih modul inventory yang diinginkan dari grid menu yang tersedia.