# Mobile Setup Instructions

## Problem
Mobile device cannot access localhost backend, causing network errors.

## Solution Steps

### 1. Find Your Computer's IP Address
```bash
# Linux/Mac
hostname -I | awk '{print $1}'

# Or use
ip route get 1 | awk '{print $7}'
```

### 2. Update Backend Configuration
Edit `backend/cmd/server/main.go` to bind to all interfaces:
```go
// Change from:
r.Run(":8000")

// To:
r.Run("0.0.0.0:8000")
```

### 3. Update Flutter Configuration
Edit `frontend/lib/utils/network_utils.dart`:
```dart
static String getRealDeviceUrl() {
  return 'http://YOUR_COMPUTER_IP:8000/api'; // Replace with actual IP
}
```

### 4. For Real Device Testing
Update the IP addresses in:
- `frontend/lib/services/api_service.dart`
- `frontend/lib/services/auth_service.dart`

Replace `10.0.2.2` with your computer's actual IP address.

### 5. Start Backend for Mobile
```bash
# Use the mobile start script
./start-mobile.sh

# Or manually
cd backend
go run cmd/server/main.go
```

### 6. Run Flutter App
```bash
cd frontend
flutter run -d YOUR_DEVICE_ID
```

## Current Configuration

### For Android Emulator:
- API URL: `http://10.0.2.2:8000/api`
- Auth URL: `http://10.0.2.2:8000/api/auth`

### For Real Android Device:
- Need to use computer's actual IP address
- Make sure both devices are on same WiFi network
- Backend must bind to `0.0.0.0:8000` not `localhost:8000`

## Troubleshooting

1. **SocketException**: Backend not accessible
   - Check if backend is running
   - Verify IP address is correct
   - Ensure firewall allows port 8000

2. **Connection Refused**: 
   - Backend not binding to correct interface
   - Use `0.0.0.0:8000` instead of `localhost:8000`

3. **Timeout**:
   - Network connectivity issues
   - Try different IP address
   - Check WiFi connection

## Quick Fix for Current Error

1. Get your computer's IP:
```bash
hostname -I | awk '{print $1}'
```

2. Replace in `auth_service.dart` and `api_service.dart`:
```dart
// Change from:
return 'http://10.0.2.2:8000/api';

// To:
return 'http://YOUR_ACTUAL_IP:8000/api';
```

3. Start backend with:
```bash
cd backend
go run cmd/server/main.go
```

Make sure backend binds to `0.0.0.0:8000` in the Go code.