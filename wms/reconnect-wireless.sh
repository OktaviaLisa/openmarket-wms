#!/bin/bash

# Default IP & Port
DEFAULT_IP="192.168.137.117"
DEFAULT_PORT="5555"

echo "=============================="
echo "   🔗 ADB Wireless Connector   "
echo "=============================="
echo "1. Gunakan IP Default ($DEFAULT_IP:$DEFAULT_PORT)"
echo "2. Masukkan IP Manual"
echo -n "Pilih opsi [1/2]: "
read choice

if [ "$choice" == "1" ]; then
    DEVICE_IP=$DEFAULT_IP
    DEVICE_PORT=$DEFAULT_PORT
elif [ "$choice" == "2" ]; then
    echo -n "Masukkan IP HP: "
    read DEVICE_IP
    echo -n "Masukkan Port [default 5555]: "
    read DEVICE_PORT
    # Kalau port kosong, pakai default 5555
    DEVICE_PORT=${DEVICE_PORT:-5555}
else
    echo "❌ Pilihan tidak valid."
    exit 1
fi

echo "🔗 Trying to connect to $DEVICE_IP:$DEVICE_PORT ..."
adb connect $DEVICE_IP:$DEVICE_PORT

echo "📱 Daftar device yang terhubung:"
adb devices
