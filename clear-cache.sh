#!/bin/bash

echo "🧹 Clearing Flutter app cache..."

# Update IP laptop terbaru
LAPTOP_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
echo "📡 Current laptop IP: $LAPTOP_IP"

# Update ApiConfig
sed -i "s/'192\.168\.1\.[0-9]\+', \/\/ IP laptop saat ini/'$LAPTOP_IP', \/\/ IP laptop saat ini/" frontend/lib/config/api_config.dart
sed -i "s/return 'http:\/\/192\.168\.1\.[0-9]\+:\$backendPort\$apiPath';/return 'http:\/\/$LAPTOP_IP:\$backendPort\$apiPath';/" frontend/lib/config/api_config.dart

echo "✅ ApiConfig updated with IP: $LAPTOP_IP"
echo "🔥 Please run 'flutter hot restart' to clear cache and apply changes"
echo "🎯 Backend should be accessible at: http://$LAPTOP_IP:8000"