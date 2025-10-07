# 🔧 Fix Login Issues - WMS Flutter

## 🚨 Masalah yang Diperbaiki

1. **Port Backend Salah** - Backend menggunakan port 8002, Flutter mencari di 8000
2. **User Tidak Ada** - User qc_inspector belum terdaftar dengan benar
3. **Login Lambat** - Timeout terlalu lama untuk network detection

## ✅ Solusi yang Diimplementasikan

### 1. Perbaikan Port Backend
- **Sebelum**: Backend di port 8002
- **Sesudah**: Backend di port 8000 (sesuai Flutter)

### 2. Penambahan User QC Inspector
- **Username**: qc_inspector
- **Password**: qc123
- **Role**: qc_inspector
- **Status**: Active

### 3. Optimasi Kecepatan Login
- **Network timeout**: 3s → 1s
- **Login timeout**: 10s → 5s
- **Health check**: Ditambahkan untuk deteksi cepat

## 🚀 Cara Menjalankan

### 1. Setup Database User
```bash
# Tambahkan user qc_inspector ke database
./setup-user.sh
```

### 2. Jalankan Backend
```bash
# Start backend server di port 8000
./start-backend.sh
```

### 3. Jalankan Flutter App
```bash
# Start Flutter app di HP fisik
./run-mobile.sh
```

### 4. Login
- **Username**: `qc_inspector`
- **Password**: `qc123`

## 🔍 Troubleshooting

### Jika Login Masih Gagal:
1. **Cek Backend**: Pastikan backend berjalan di port 8000
2. **Cek Database**: Pastikan user qc_inspector ada di database
3. **Cek Network**: Pastikan HP dan laptop di WiFi yang sama

### Jika Login Masih Lambat:
1. **Cek WiFi**: Pastikan koneksi WiFi stabil
2. **Restart App**: Close dan buka ulang Flutter app
3. **Clear Cache**: Uninstall dan install ulang app

## 📝 Kredensial Login

```
Username: qc_inspector
Password: qc123
Role: QC Inspector
```

## ✨ Hasil Akhir

✅ **Login Cepat** - Maksimal 5 detik
✅ **Auto-Discovery** - Otomatis cari backend
✅ **User Ready** - qc_inspector siap digunakan
✅ **Port Correct** - Backend di port 8000

---
*Login issue resolved! 🎉*