#!/bin/bash

echo "[+] Installing Trace-it CLI..."

# Detect environment
if command -v apt &>/dev/null; then
  ENV="debian"
elif command -v pkg &>/dev/null; then
  ENV="termux"
else
  ENV="unknown"
fi

# Make main script executable
chmod +x trace.sh
mv trace.sh trace

# Install binary
if [[ "$EUID" -eq 0 ]]; then
  echo "[✓] Running as root. Installing globally..."
  mv trace /usr/local/bin/
  echo "[✓] Installed at /usr/local/bin/trace"
else
  echo "[!] Not running as root. Installing locally..."

  if [[ "$ENV" == "debian" ]]; then
    mkdir -p "$HOME/.local/bin"
    mv trace "$HOME/.local/bin/"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    echo "[✓] Installed at ~/.local/bin/trace"
  elif [[ "$ENV" == "termux" ]]; then
    mkdir -p "$HOME/bin"
    mv trace "$HOME/bin/"
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    echo "[✓] Installed at ~/bin/trace"
  else
    echo "[!] Unsupported environment. Please move 'trace' to a PATH directory manually."
  fi
fi

# Install dependencies
echo "[+] Installing required packages..."
if [[ "$ENV" == "debian" ]]; then
  apt update && apt install curl jq dnsutils net-tools nmap wireless-tools network-manager bluez -y
elif [[ "$ENV" == "termux" ]]; then
  pkg update && pkg install curl jq dnsutils net-tools nmap wireless-tools network-manager bluez -y
else
  echo "[!] Please install manually: curl, jq, dig, arp, hostname, ip, nmap, iwlist, nmcli, bluetoothctl"
fi
echo "[✓] Installation complete. You can now use the 'trace' command."
