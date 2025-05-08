#!/bin/bash

echo "📶 Scanning for available Wi-Fi networks..."
sudo iwlist wlan0 scan | grep ESSID

read -p "Enter SSID (Wi-Fi name): " ssid
read -sp "Enter Password: " psk
echo


sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.backup

sudo bash -c "cat > /etc/wpa_supplicant/wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=MY

network={
    ssid=\"$ssid\"
    psk=\"$psk\"
}
EOF"


echo "🔁 Applying Wi-Fi settings..."
sudo wpa_cli -i wlan0 reconfigure
sleep 5


echo "🌐 Checking IP address..."
ip=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
if [ -n "$ip" ]; then
    echo "✅ Connected! IP Address: $ip"
else
    echo "❌ No IP address assigned to wlan0."
fi


ssid_connected=$(iwgetid wlan0 --raw)
if [ -n "$ssid_connected" ]; then
    echo "📡 Connected to SSID: $ssid_connected"
else
    echo "❌ Not connected to any SSID."
fi


echo "🔎 Testing internet connection..."
if ping -c 2 8.8.8.8 > /dev/null 2>&1; then
    echo "✅ Internet connection is working."
else
    echo "⚠️ No internet access (check gateway or DNS)."
fi
