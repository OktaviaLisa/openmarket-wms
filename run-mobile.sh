#!/bin/bash

# Script untuk menjalankan Flutter app di HP fisik
echo "🚀 Starting WMS Flutter App on Physical Device..."
echo "📱 Make sure your phone and laptop are on the same WiFi network"
echo "🔍 App will automatically detect backend server IP"

# Pindah ke direktori frontend
cd frontend

# Jalankan flutter dengan device fisik
flutter run -d 192.168.1.122:5555 --hot

echo "✅ App started successfully!"
echo "💡 If login fails, the app will automatically search for backend server"
echo "🔄 You can switch WiFi networks and the app will adapt automatically"