# LOGIN CREDENTIALS YANG BEKERJA

## Untuk Container pkl-wms yang baru:

**Username:** qc_inspector  
**Password:** qc123

## Cara Login:
1. Buka browser ke http://localhost:3000
2. Masukkan:
   - Username: qc_inspector
   - Password: qc123

## Jika masih tidak bisa login:
Jalankan script ini untuk membuat user yang pasti bekerja:

```bash
# 1. Hapus user lama
docker exec -i db psql -U wms_user -d wms_db -c "DELETE FROM auth_user WHERE username = 'qc_inspector';"

# 2. Buat user baru dengan password hash yang benar
docker exec -i db psql -U wms_user -d wms_db -c "INSERT INTO auth_user (username, email, password, first_name, last_name, roles, is_staff, is_superuser, is_active, date_joined) VALUES ('qc_inspector', 'qc@wms.com', '$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPJSMJTOy', 'QC', 'Inspector', 'qc', false, false, true, NOW());"
```

## Test Login via API:
```bash
curl -X POST http://localhost:8000/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"qc_inspector\",\"password\":\"qc123\"}"
```

User sudah dibuat dan siap digunakan untuk login ke website!