#!/bin/bash

echo "[+] Installing Trace-it CLI..."
echo "------------------------------------------"

OS=$(uname -s)

# ===========================================================
# VERIFY trace.sh EXISTS
# ===========================================================
if [[ ! -f "trace.sh" ]]; then
    echo "[!] ERROR: trace.sh not found!"
    echo "Place setup.sh and trace.sh in the SAME directory."
    exit 1
fi

# ===========================================================
# PREPARE CLI WRAPPER
# ===========================================================
echo "[+] Making script executable..."
chmod +x trace.sh

# Create wrapper command
echo '#!/bin/bash' > trace
echo 'bash "$(dirname $0)/Trace-ip/trace.sh" "$@"' >> trace
chmod +x trace

# ===========================================================
# INSTALL FULL FOLDER + CLI COMMAND
# ===========================================================
if [[ "$EUID" -eq 0 ]]; then
    echo "[+] Installing globally (root)..."

    # Move entire folder
    TARGET="/usr/bin/Trace-ip"
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    cp -r ./* "$TARGET/"

    # Move CLI wrapper
    mv -f trace /usr/bin/trace
    chmod +x "/usr/bin/trace"
    echo "[✓] Installed"
else
    echo "[+] not rooted "

    TARGET="$HOME/.local/bin/Trace-ip"
    mkdir -p "$TARGET"
    cp -r ./* "$TARGET/"

    mkdir -p "$HOME/.local/bin"
    mv -f trace "$HOME/.local/bin/trace"
    chmod +x "$HOME/.local/bin/trace"

    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    echo "setup successful!"
fi

echo ""
echo "[Trace-it] Dependency Checker"
echo "------------------------------------------"

# ===========================================================
# REQUIRED TOOLS
# ===========================================================
REQUIRED_TOOLS=(curl jq dig arp hostname ip nmap iwlist nmcli bluetoothctl)

# ===========================================================
# INSTALL FUNCTIONS
# ===========================================================
install_linux() {
    if command -v sudo >/dev/null 2>&1; then
        apt update -y
        apt install -y "$@"
    else
        sudo apt update -y 2>/dev/null
        sudo apt install -y "$@" 2>/dev/null
    fi
}

install_termux() {
    pkg update -y
    pkg install -y "$@"
}

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "[!] Homebrew not installed → installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install "$@"
}

# ===========================================================
# DETECT ENVIRONMENT
# ===========================================================
if command -v pkg >/dev/null 2>&1; then
    ENV="termux"
elif command -v apt >/dev/null 2>&1; then
    ENV="linux"
elif [[ "$OS" == "Darwin" ]]; then
    ENV="macos"
else
    ENV="unknown"
fi

echo "Detected environment: $ENV"
echo ""

# ===========================================================
# CHECK MISSING TOOLS
# ===========================================================
MISSING=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING+=("$tool")
    fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "[✓] All dependencies already installed!"
    echo "[✓] Setup complete → run: trace "
    exit 0
fi

echo "Missing tools:"
printf ' - %s\n' "${MISSING[@]}"
echo ""

# ===========================================================
# INSTALL MISSING PACKAGES
# ===========================================================
case $ENV in
    linux)
        echo "[+] Installing tools (Linux/WSL)..."
        install_linux "${MISSING[@]}"
        ;;
    termux)
        echo "[+] Installing tools (Termux)..."
        install_termux "${MISSING[@]}"
        ;;
    macos)
        echo "[+] Installing tools (macOS)..."
        install_macos "${MISSING[@]}"
        ;;
    *)
        echo "[!] Unsupported OS → install manually:"
        printf '   %s\n' "${MISSING[@]}"
        ;;
esac

echo ""
echo "[✓] Setup finished successfully!"
echo "Run your tool using:  trace "
