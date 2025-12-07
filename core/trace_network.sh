#!/bin/bash

# ======================================================
#  Trace-it : Universal Cross-Platform Scanner (SAFE)
#  File Name: trace_network.sh
#  Usage: trace -net
#  Works on Linux, macOS, WSL, Termux, Rooted & Non-Rooted
# ======================================================

OS=$(uname -s)

clear
echo "[Trace-it] Universal Network, Wi-Fi & Bluetooth Scanner"
echo "--------------------------------------------------------"
echo "Detected OS: $OS"
echo ""

# ======================================================
#  INTERFACE DETECTION (SAFE MODE)
# ======================================================
detect_interface() {

    iface=""

    # Linux (physical adapters)
    if [[ -d /sys/class/net ]]; then
        iface=$(ls /sys/class/net | grep -Ev 'lo|docker|vir|veth|br|tun' | head -n 1)
    fi

    # macOS
    if [[ "$OS" == "Darwin" ]]; then
        iface=$(networksetup -listallhardwareports 2>/dev/null | awk '/Device/ {print $2; exit}')
    fi

    # Android (Termux)
    if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then
        iface="wlan0"
    fi

    # Fallback for WSL / VM / No hardware
    if [[ -z "$iface" ]]; then
        echo "⚠ No network interfaces detected. Using offline mode."
        iface="none"
    fi

    echo "$iface"
}

interface=$(detect_interface)
echo "Using interface: $interface"
echo ""

# ======================================================
#  LOCAL IP + SUBNET (SAFE MODE)
# ======================================================
local_ip=""

if [[ "$interface" != "none" ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        local_ip=$(ipconfig getifaddr "$interface" 2>/dev/null)
    else
        local_ip=$(ip -o -4 addr show "$interface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
    fi
fi

if [[ -z "$local_ip" ]]; then
    echo "⚠ No real IP detected → Using 127.0.0.1 (offline mode)"
    local_ip="127.0.0.1"
fi

subnet_prefix=$(echo "$local_ip" | cut -d. -f1-3 2>/dev/null)
subnet="${subnet_prefix}.0/24"

echo "Local IP: $local_ip"
echo "Subnet:   $subnet"
echo ""

# ======================================================
#  1. NETWORK SCAN
# ======================================================
echo "[1] Scanning LAN devices..."
echo ""

if command -v nmap >/dev/null 2>&1 && [[ "$interface" != "none" ]]; then
    nmap -sn "$subnet" 2>/dev/null | awk '
        /Nmap scan report for/ {
            ip=$5
            getline
            status = ($0 ~ /Host is up/) ? "Up" : "Down"
            getline
            if ($0 ~ /MAC Address:/) {
                mac=$3
                vendor=""
                for(i=4;i<=NF;i++) vendor=vendor" "$i
            } else {
                mac="N/A"; vendor="Unknown"
            }
            printf "%-20s %-20s %-20s %-10s\n", ip, mac, vendor, status
        }'
else
    echo "ℹ LAN scan disabled (no network OR nmap missing)."
fi

echo ""
echo "--------------------------------------------------------"
echo ""

# ======================================================
#  2. WI-FI SCAN
# ======================================================
echo "[2] Scanning Wi-Fi networks..."
echo ""

if command -v nmcli >/dev/null 2>&1; then
    nmcli -f SSID,BSSID,CHAN,SIGNAL device wifi list 2>/dev/null | tail -n +2

elif command -v iwlist >/dev/null 2>&1 && [[ "$interface" != "none" ]]; then
    iwlist "$interface" scan 2>/dev/null | awk '
        /ESSID/ {gsub(/"/,""); ssid=$2}
        /Address:/ {bssid=$5}
        /Channel:/ {channel=$2}
        /Signal level/ {signal=$3}
        /Encryption key:/ {
            printf "%-30s %-20s %-10s %-15s\n", ssid, bssid, channel, signal
            ssid=""; bssid=""; channel=""; signal=""
        }'

elif [[ "$OS" == "Darwin" ]] && command -v airport >/dev/null 2>&1; then
    airport -s

else
    echo "ℹ Wi-Fi scan not supported (no adapter OR no tools)."
fi

echo ""
echo "--------------------------------------------------------"
echo ""

# ======================================================
#  3. BLUETOOTH SCAN
# ======================================================
echo "[3] Scanning Bluetooth devices..."
echo ""

if command -v bluetoothctl >/dev/null 2>&1; then
    bluetoothctl scan on >/dev/null 2>&1 &
    pid=$!
    sleep 4
    kill "$pid" >/dev/null 2>&1
    bluetoothctl scan off >/dev/null 2>&1

    bluetoothctl devices | awk '
        {
            mac=$2
            name=""
            for(i=3;i<=NF;i++) name=name" "$i
            printf "%-20s %-25s\n", mac, name
        }'

else
    echo "ℹ Bluetooth scan not supported (no bluetoothctl)."
fi

echo ""
echo "--------------------------------------------------------"
echo ""

# ======================================================
#  4. ARP TABLE
# ======================================================
echo "[4] ARP Table:"
echo ""

if command -v arp >/dev/null 2>&1; then
    arp -a 2>/dev/null | awk '
        {
            split($2,ip,"[()]")
            printf "%-25s %-20s %-20s\n", $1, ip[2], $4
        }'
else
    echo "ℹ ARP tool missing."
fi

echo ""
echo "--------------------------------------------------------"
echo ""
echo "Scan complete."
echo "Press Enter to exit..."
read
clear
