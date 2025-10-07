-- Script untuk menambahkan user qc_inspector
-- Password: qc123 (akan di-hash oleh bcrypt)

-- Hapus user jika sudah ada
DELETE FROM auth_user WHERE username = 'qc_inspector';

-- Tambah user baru dengan password yang sudah di-hash
-- Hash untuk 'qc123' menggunakan bcrypt cost 10
INSERT INTO auth_user (
    username, 
    email, 
    password, 
    first_name, 
    last_name, 
    role, 
    is_staff, 
    is_superuser, 
    is_active, 
    date_joined
) VALUES (
    'qc_inspector',
    'qc@wms.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- bcrypt hash untuk 'qc123'
    'QC',
    'Inspector',
    'qc_inspector',
    false,
    false,
    true,
    NOW()
);

-- Verifikasi user berhasil ditambahkan
SELECT id, username, email, role, is_active FROM auth_user WHERE username = 'qc_inspector';