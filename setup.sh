#!/bin/bash
# ===========================================================
# Trace-it Universal Installer (Root Optional + Robust Wrapper)
# Supports: install | --update | --uninstall
# ===========================================================

APP_NAME="Trace-ip"
REPO_URL="https://github.com/Cyberdavil0/Trace-ip.git"

# ===========================================================
# Detect Install Location
# ===========================================================

if [[ "$EUID" -eq 0 ]]; then
    INSTALL_DIR="/usr/bin/Trace-ip"
    BIN_PATH="/usr/bin/trace"
    MODE="global"
else
    INSTALL_DIR="$HOME/.local/bin/Trace-ip"
    BIN_PATH="$HOME/.local/bin/trace"
    MODE="local"
fi

# ===========================================================
# INSTALL FUNCTION
# ===========================================================
install_app() {
    echo "[+] Installing $APP_NAME ($MODE mode)..."

    # Remove old files if any
    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"

    # Copy current folder contents to install dir
    cp -r "$(pwd)"/* "$INSTALL_DIR/"

    # Create robust wrapper
    mkdir -p "$(dirname "$BIN_PATH")"
    cat <<'EOF' > "$BIN_PATH"
#!/bin/bash
# ===========================================================
# Trace-it Robust Wrapper
# ===========================================================

# Determine installation location
if [[ -d "/usr/bin/Trace-ip" ]]; then
    TRACE_DIR="/usr/bin/Trace-ip"
elif [[ -d "$HOME/.local/bin/Trace-ip" ]]; then
    TRACE_DIR="$HOME/.local/bin/Trace-ip"
else
    echo "[!] Trace-it not installed. Run setup.sh first."
    exit 1
fi

TRACE_SCRIPT="$TRACE_DIR/trace.sh"
if [[ ! -f "$TRACE_SCRIPT" ]]; then
    echo "[!] trace.sh missing in $TRACE_DIR"
    exit 1
fi

# Optional dependency check
REQUIRED_TOOLS=(bash curl jq dig nmap ip arp hostname)
MISSING=()
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING+=("$tool")
    fi
done
if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "[!] Missing dependencies: ${MISSING[*]}"
    echo "Install them and try again."
    exit 1
fi

# Run actual trace.sh
exec bash "$TRACE_SCRIPT" "$@"
EOF

    chmod +x "$BIN_PATH"
    chmod +x "$INSTALL_DIR/trace.sh"

    # Add PATH for local install
    if [[ "$MODE" == "local" ]]; then
        if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
            echo "[+] Added ~/.local/bin to PATH"
        fi
    fi

    echo "[✓] Installation complete!"
    echo "Run the tool using: trace"
}

# ===========================================================
# UNINSTALL FUNCTION
# ===========================================================
uninstall_app() {
    echo "[+] Removing $APP_NAME..."
    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_PATH"
    echo "[✓] Uninstalled successfully."
}

# ===========================================================
# UPDATE FUNCTION
# ===========================================================
update_app() {
    echo "[+] Updating $APP_NAME from GitHub..."

    TMP_DIR="/tmp/trace_update"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    wget -q "$REPO_URL" -O "$TMP_DIR/update.zip" || {
        echo "[!] Download failed."
        exit 1
    }

    unzip -q "$TMP_DIR/update.zip" -d "$TMP_DIR"

    NEW_DIR=$(find "$TMP_DIR" -type d -name "Trace-ip-*")
    if [[ -z "$NEW_DIR" ]]; then
        echo "[!] Extraction failed."
        exit 1
    fi

    rm -rf "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    cp -r "$NEW_DIR"/* "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/trace.sh"

    echo "[✓] Update complete!"
}

# ===========================================================
# SHOW HELP
# ===========================================================
show_help() {
    echo "Trace-it Installer"
    echo ""
    echo "Usage:"
    echo "  ./setup.sh             → Install"
    echo "  ./setup.sh --update    → Update from GitHub"
    echo "  ./setup.sh --uninstall → Remove tool"
    echo ""
    echo "Tip: Run with sudo for global install."
}

# ===========================================================
# MAIN LOGIC
# ===========================================================
case "$1" in
    --update)
        update_app
        ;;
    --uninstall)
        uninstall_app
        ;;
    "")
        install_app
        ;;
    *)
        show_help
        ;;
esac
