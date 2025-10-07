# 📦 Panduan Penggunaan Form Penerimaan Barang

## 🔧 Perbaikan Error "FormatException: Invalid radix-10 number"

**Masalah yang diperbaiki:**
- Error terjadi karena field numerik mencoba mengkonversi nilai `null` atau string kosong menjadi angka
- Validasi input yang tidak proper
- Tidak ada handling untuk input yang tidak valid

**Solusi yang diimplementasikan:**
- ✅ Validasi input yang ketat dengan `TextFormField.validator`
- ✅ Input formatter untuk field numerik (`FilteringTextInputFormatter.digitsOnly`)
- ✅ Try-catch untuk parsing angka dengan error handling
- ✅ Petunjuk pengisian yang jelas di dalam form

---

## 📋 Cara Penggunaan Form Penerimaan Barang

### 1. **Akses Form**
- Buka screen "Penerimaan Barang"
- Tap tombol **"+ Tambah Penerimaan"** (floating action button)

### 2. **Pengisian Form**

#### **🏷️ Nama Produk** *(Wajib)*
- **Format**: Teks bebas, minimal 3 karakter
- **Contoh**: `Laptop Dell XPS 13`, `Mouse Wireless Logitech`
- **Fitur**: Dropdown dengan saran produk yang tersedia
- **Validasi**: 
  - Tidak boleh kosong
  - Minimal 3 karakter

#### **🔢 Jumlah** *(Wajib)*
- **Format**: Angka saja (1-10000)
- **Contoh**: `10`, `25`, `100`
- **Validasi**:
  - Hanya menerima angka
  - Tidak boleh kosong
  - Harus lebih dari 0
  - Maksimal 10.000 unit
- **Unit**: Otomatis menampilkan "unit"

#### **🏢 Supplier** *(Wajib)*
- **Format**: Teks bebas, minimal 3 karakter
- **Contoh**: `PT. Tech Solutions`, `CV. Elektronik Jaya`
- **Validasi**:
  - Tidak boleh kosong
  - Minimal 3 karakter

#### **📊 Status** *(Wajib)*
- **Pilihan**:
  - `Menunggu` - Barang belum diterima
  - `Diterima` - Barang sudah diterima
  - `Quality Check` - Sedang dalam pemeriksaan kualitas
  - `Selesai` - Proses penerimaan selesai
- **Default**: Menunggu

#### **📅 Tanggal Penerimaan** *(Wajib)*
- **Format**: Otomatis dari date picker
- **Range**: 30 hari ke belakang sampai 30 hari ke depan
- **Default**: Hari ini

#### **📝 Catatan** *(Opsional)*
- **Format**: Teks bebas, maksimal 3 baris
- **Contoh**: `Barang dalam kondisi baik`, `Perlu pengecekan tambahan`

### 3. **Validasi Form**

Form akan melakukan validasi otomatis saat tombol **"Simpan"** ditekan:

```
✅ Semua field wajib (*) harus diisi
✅ Jumlah harus berupa angka valid
✅ Nama produk dan supplier minimal 3 karakter
✅ Tanggal dalam range yang diizinkan
```

### 4. **Pesan Error dan Solusinya**

| Error | Penyebab | Solusi |
|-------|----------|--------|
| "Nama produk wajib diisi" | Field kosong | Isi nama produk |
| "Nama produk minimal 3 karakter" | Input terlalu pendek | Tambahkan karakter |
| "Jumlah wajib diisi" | Field kosong | Isi jumlah |
| "Jumlah harus berupa angka" | Input bukan angka | Masukkan angka saja |
| "Jumlah harus lebih dari 0" | Input 0 atau negatif | Masukkan angka positif |
| "Jumlah maksimal 10.000" | Input terlalu besar | Kurangi jumlah |
| "Supplier wajib diisi" | Field kosong | Isi nama supplier |
| "Format jumlah tidak valid" | Error parsing | Hapus dan ketik ulang angka |

---

## 🎯 Contoh Pengisian yang Benar

### **Contoh 1: Penerimaan Laptop**
```
Nama Produk: Laptop Dell XPS 13
Jumlah: 5
Supplier: PT. Tech Solutions
Status: Diterima
Tanggal: 19/01/2024
Catatan: Kondisi baik, sudah dicek
```

### **Contoh 2: Penerimaan Aksesoris**
```
Nama Produk: Mouse Wireless Logitech
Jumlah: 25
Supplier: CV. Elektronik Jaya
Status: Quality Check
Tanggal: 19/01/2024
Catatan: Perlu pengecekan fungsi wireless
```

### **Contoh 3: Penerimaan Bulk**
```
Nama Produk: Keyboard Mechanical
Jumlah: 100
Supplier: PT. Hardware Indonesia
Status: Menunggu
Tanggal: 20/01/2024
Catatan: -
```

---

## 🚀 Fitur Tambahan

### **1. Saran Produk**
- Tap ikon dropdown di field "Nama Produk"
- Pilih dari daftar produk yang tersedia
- Otomatis mengisi field

### **2. Input Validation Real-time**
- Error muncul langsung saat input tidak valid
- Warna merah pada field yang error
- Pesan error spesifik untuk setiap masalah

### **3. Date Picker**
- Tap field tanggal untuk membuka kalender
- Navigasi mudah dengan swipe
- Tema orange sesuai aplikasi

### **4. Responsive Design**
- Form menyesuaikan ukuran layar
- Scroll otomatis jika konten panjang
- Button placement yang optimal

---

## 🔍 Tips Penggunaan

1. **Isi field wajib terlebih dahulu** - Field dengan tanda (*) harus diisi
2. **Gunakan angka saja untuk jumlah** - Jangan tambahkan teks seperti "unit"
3. **Pilih tanggal yang realistis** - Sesuaikan dengan jadwal penerimaan
4. **Manfaatkan saran produk** - Untuk konsistensi nama produk
5. **Tambahkan catatan jika perlu** - Untuk informasi tambahan yang penting

---

## 📱 Tampilan Form

Form memiliki:
- **Header berwarna orange** dengan judul dan tombol close
- **Info box biru** dengan petunjuk pengisian
- **Field yang terorganisir** dengan label yang jelas
- **Validasi visual** dengan border merah untuk error
- **Action buttons** di bagian bawah (Batal/Simpan)

---

## ✅ Hasil Setelah Penyimpanan

Setelah berhasil menyimpan:
1. Form akan tertutup otomatis
2. Data muncul di list penerimaan
3. Notifikasi sukses ditampilkan
4. Status chip berwarna sesuai status yang dipilih

---

**💡 Catatan**: Jika masih mengalami error, pastikan semua field wajib sudah diisi dengan format yang benar, terutama field "Jumlah" yang harus berupa angka saja.