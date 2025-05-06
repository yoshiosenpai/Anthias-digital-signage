#!/bin/bash

# Step 1: Run Anthias official installer
echo "📦 Installing Screenly Anthias..."
bash <(curl -sL https://install-anthias.srly.io)

# Step 2: Create unblock-wifi.sh script
echo "📄 Creating Wi-Fi unblock script..."
cat << 'EOF' | sudo tee /usr/local/bin/unblock-wifi.sh > /dev/null
#!/bin/bash
/usr/sbin/rfkill unblock wifi
/usr/sbin/rfkill unblock all
/sbin/ip link set wlan0 up
EOF

sudo chmod +x /usr/local/bin/unblock-wifi.sh

# Step 3: Create systemd service
echo "⚙️ Setting up systemd service..."
cat << EOF | sudo tee /etc/systemd/system/unblock-wifi.service > /dev/null
[Unit]
Description=Unblock Wi-Fi on boot
After=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/unblock-wifi.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Step 4: Enable and start service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable unblock-wifi.service
sudo systemctl start unblock-wifi.service

# Step 5: Ask user to reboot
echo ""
read -p "✅ Setup complete! Do you want to reboot now? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo "♻️ Rebooting system..."
    sudo reboot
else
    echo "👍 Reboot skipped. Please reboot manually when ready."
fi
