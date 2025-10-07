#!/bin/bash

# Get laptop IP address
LAPTOP_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')

echo "🖥️  Laptop IP: $LAPTOP_IP"
echo "🔗 Backend URL: http://$LAPTOP_IP:8000/api"
echo "🏥 Health Check: http://$LAPTOP_IP:8000/api/health"

# Test backend connection
echo "🧪 Testing backend connection..."
if curl -s "http://$LAPTOP_IP:8000/api/health" > /dev/null; then
    echo "✅ Backend is accessible at http://$LAPTOP_IP:8000"
else
    echo "❌ Backend is not accessible"
fi