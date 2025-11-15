#!/bin/bash

source utils/validator.sh
check_dependencies || exit 1

clear
echo "[Trace-it] Scanning all nearby devices (network, Wi-Fi, Bluetooth)..."
echo "----------------------------------------"

echo "1. Scanning local network devices (connected and disconnected):"
echo ""

# Get the local IP and subnet
local_ip=$(hostname -I | awk '{print $1}')
if [[ -z "$local_ip" ]]; then
  local_ip=$(ip route get 8.8.8.8 | awk '{print $7; exit}')
fi
subnet=$(echo "$local_ip" | awk -F. '{print $1"."$2"."$3".0/24"}')

echo "Subnet: $subnet"

# Use nmap to scan the entire subnet for all devices (up or down)
nmap -sn "$subnet" | awk '
BEGIN {
  printf "%-25s %-20s %-20s %-10s\n", "Device", "IP Address", "MAC Address", "Status"
  print "─────────────────────────────────────────────────────────────────────────────────────────────────"
}
/Nmap scan report for/ {
  ip = $5
  getline
  if ($0 ~ /Host is up/) {
    status = "Up"
    getline
    if ($0 ~ /MAC Address:/) {
      split($0, arr, ": ")
      mac_addr = arr[2]
      split(mac_addr, parts, " ")
      mac_clean = parts[1]
      device = ""
      for (i=2; i<=length(parts); i++) device = device (i>2 ? " " : "") parts[i]
      if (device == "") device = "Unknown"
    } else {
      mac_clean = "N/A"
      device = "Unknown"
    }
  } else {
    status = "Down"
    mac_clean = "N/A"
    device = "Unknown"
  }
  printf "%-25s %-20s %-20s %-10s\n", device, ip, mac_clean, status
}
'

echo -e "\n2. Scanning nearby Wi-Fi networks (access points):"
echo ""

# Scan for Wi-Fi networks using iwlist or nmcli
if command -v iwlist &>/dev/null; then
  iwlist wlan0 scan 2>/dev/null | awk '
  BEGIN {
    printf "%-30s %-20s %-10s %-15s\n", "SSID", "BSSID", "Channel", "Signal"
    print "─────────────────────────────────────────────────────────────────────────────────────────────"
  }
  /Cell/ { cell++ }
  /ESSID:/ { split($0, essid, ":"); ssid = substr(essid[2], 2, length(essid[2])-2) }
  /Address:/ { bssid = $5 }
  /Channel:/ { channel = $2 }
  /Signal level=/ { signal = $3 }
  /Encryption key:/ { encryption = $3; printf "%-30s %-20s %-10s %-15s\n", ssid, bssid, channel, signal; ssid=""; bssid=""; channel=""; signal="" }
  '
elif command -v nmcli &>/dev/null; then
  nmcli device wifi list | awk '
  NR>1 {
    printf "%-30s %-20s %-10s %-15s\n", $2, $1, $4, $6
  }
  ' | head -20
else
  echo "Wi-Fi scanning not available (install iwlist or nmcli)"
fi

echo -e "\n3. Scanning nearby Bluetooth devices:"
echo ""

# Scan for Bluetooth devices
if command -v bluetoothctl &>/dev/null; then
  bluetoothctl scan on &
  sleep 5
  bluetoothctl devices | awk '
  BEGIN {
    printf "%-20s %-25s\n", "MAC Address", "Device Name"
    print "─────────────────────────────────────────────────────"
  }
  {
    mac = $2
    name = ""
    for (i=3; i<=NF; i++) name = name (i>3 ? " " : "") $i
    printf "%-20s %-25s\n", mac, name
  }
  '
  bluetoothctl scan off
else
  echo "Bluetooth scanning not available (install bluetoothctl)"
fi

echo -e "\nARP Table (currently connected devices):"
arp -a | awk '
BEGIN {
  printf "%-25s %-20s %-20s\n", "Device", "IP Address", "MAC Address"
  print "───────────────────────────────────────────────────────────────────────────────"
}
{
  split($2, ip, "[()]")
  printf "%-25s %-20s %-20s\n", $1, ip[2], $4
}
'

echo -e "\n⏳ Press Enter or Ctrl+C to clear screen..."
read -r
clear
