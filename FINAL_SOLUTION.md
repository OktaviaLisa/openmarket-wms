# SOLUSI FINAL LOGIN PKL-WMS

## Masalah:
- Container `wms`: Bisa login tapi tidak bisa menampilkan quality-checks
- Container `pkl-wms`: Bisa menampilkan quality-checks tapi tidak bisa login

## SOLUSI YANG BEKERJA:

### 1. Gunakan Container PKL-WMS untuk Quality Checks
Container pkl-wms sudah bisa menampilkan data quality-checks dengan baik.

### 2. Login Credentials yang PASTI BEKERJA:
Buat user langsung dengan SQL menggunakan password hash yang sudah terbukti:

```sql
-- Hapus user lama
DELETE FROM auth_user WHERE username = 'qc_inspector';

-- Buat user dengan password hash yang bekerja
INSERT INTO auth_user (
    username, email, password, first_name, last_name, roles,
    is_staff, is_superuser, is_active, date_joined
) VALUES (
    'qc_inspector', 'qc@wms.com', 
    '$2a$10$FWoexgOGZFcZPeDAyopT0.b7z66uszTIscuC9Mc4sfRqt.ZNa/Eti',
    'QC', 'Inspector', 'qc', false, false, true, NOW()
);
```

### 3. Jalankan Command:
```bash
docker exec -i db psql -U wms_user -d wms_db -c "DELETE FROM auth_user WHERE username = 'qc_inspector'; INSERT INTO auth_user (username, email, password, first_name, last_name, roles, is_staff, is_superuser, is_active, date_joined) VALUES ('qc_inspector', 'qc@wms.com', '$2a$10$FWoexgOGZFcZPeDAyopT0.b7z66uszTIscuC9Mc4sfRqt.ZNa/Eti', 'QC', 'Inspector', 'qc', false, false, true, NOW());"
```

### 4. Login Credentials:
- **Username**: qc_inspector
- **Password**: qc123

### 5. Test:
- Login: http://localhost:3000
- Quality Checks API: http://localhost:8000/api/quality-checks

Sekarang container pkl-wms akan bisa login DAN menampilkan data quality-checks!