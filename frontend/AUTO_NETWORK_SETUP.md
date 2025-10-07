# Auto Network Detection Setup

Sistem auto-detection untuk backend URL yang secara otomatis mendeteksi IP address server berdasarkan jaringan WiFi yang digunakan.

## Fitur

✅ **Auto-detect Gateway IP** - Menggunakan IP gateway WiFi sebagai kandidat pertama
✅ **Subnet Scanning** - Scan IP umum di subnet yang sama dengan perangkat
✅ **Quick Test** - Test IP address yang paling umum digunakan
✅ **Caching** - Simpan URL yang berhasil untuk akses lebih cepat
✅ **Fallback** - Gunakan localhost jika tidak ada yang ditemukan
✅ **Network Info** - Tampilkan info jaringan untuk debugging

## Cara Kerja

1. **Gateway Detection**: Coba IP gateway WiFi (biasanya router)
2. **Subnet Scanning**: Scan IP umum di subnet yang sama (x.x.x.1, x.x.x.100, dll)
3. **Quick Test**: Test IP address yang sering digunakan
4. **Caching**: Simpan URL yang berhasil untuk penggunaan selanjutnya
5. **Fallback**: Gunakan localhost jika semua gagal

## Penggunaan

### 1. Import dan Setup

```dart
import 'package:wms_frontend/services/api_service.dart';
import 'package:wms_frontend/config/api_config.dart';

// ApiService akan otomatis menggunakan auto-detection
final apiService = ApiService();
```

### 2. Manual Network Info

```dart
// Dapatkan info jaringan saat ini
final networkInfo = await ApiConfig.getCurrentNetworkInfo();
print('WiFi: ${networkInfo['wifiName']}');
print('Device IP: ${networkInfo['wifiIP']}');
print('Gateway: ${networkInfo['wifiGateway']}');

// Reset cache untuk re-detection
await ApiConfig.resetCache();
```

### 3. Widget untuk Monitoring

```dart
import 'package:wms_frontend/widgets/network_status_widget.dart';

// Tampilkan status jaringan
NetworkStatusWidget()
```

## Testing

Jalankan contoh aplikasi:

```bash
cd frontend
flutter run lib/example_auto_network.dart
```

## IP Address yang Dicoba

### Gateway IP
- IP gateway WiFi (dari network_info_plus)

### Subnet Scanning
- x.x.x.1 (router)
- x.x.x.100, x.x.x.101, x.x.x.102 (server umum)
- x.x.x.177 (IP khusus project)
- x.x.x.200, x.x.x.254 (IP alternatif)

### Quick Test IPs
- 192.168.1.100, 192.168.1.101
- 192.168.0.100, 192.168.0.101
- 192.168.43.1 (mobile hotspot)
- 192.168.137.1 (Windows hotspot)
- 10.0.2.2 (Android emulator)
- localhost

## Konfigurasi

Edit `lib/config/api_config.dart` untuk menyesuaikan:

```dart
class ApiConfig {
  static const int port = 8000;           // Port backend
  static const String apiPath = '/api';   // API path
  static const Duration timeout = Duration(seconds: 3); // Timeout test
}
```

## Debugging

1. **Lihat Console**: Auto-detection akan print URL yang ditemukan
2. **Network Status Widget**: Tampilkan info jaringan real-time
3. **Manual Reset**: Reset cache jika ada masalah

```dart
// Debug network detection
final url = await ApiConfig.getAutoDetectedBaseUrl();
print('Detected URL: $url');

// Reset jika ada masalah
await ApiConfig.resetCache();
```

## Troubleshooting

### Backend Tidak Ditemukan
1. Pastikan backend berjalan di port 8000
2. Cek firewall tidak memblokir koneksi
3. Pastikan perangkat dan server di jaringan yang sama

### IP Address Salah
1. Reset cache: `await ApiConfig.resetCache()`
2. Restart aplikasi
3. Cek info jaringan di NetworkStatusWidget

### Koneksi Lambat
1. Kurangi timeout di ApiConfig
2. Tambahkan IP server ke quick test list
3. Gunakan IP statis jika perlu

## Integrasi dengan Aplikasi Utama

Ganti import di `lib/services/api_service.dart`:

```dart
// Ganti ini
import '../config/network_config.dart';

// Dengan ini
import '../config/api_config.dart';

// Update method baseUrl
static Future<String> get baseUrl async {
  return await ApiConfig.getAutoDetectedBaseUrl();
}
```

Sistem akan otomatis bekerja tanpa perubahan kode lain.