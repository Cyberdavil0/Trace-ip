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
echo "[+] Making scripts executable..."
chmod +x trace.sh

# Create wrapper command
echo '#!/bin/bash' > trace
echo 'bash "$(dirname "$0")/Trace-ip/trace.sh" "$@"' >> trace
chmod +x trace

# ===========================================================
# INSTALL FULL TOOL FOLDER + CLI COMMAND
# ===========================================================
if [[ "$EUID" -eq 0 ]]; then
    echo "[+] Installing globally (root)..."

    TARGET="/usr/bin/Trace-ip"
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    cp -r ./* "$TARGET/"

    mv -f trace /usr/bin/trace
    chmod +x /usr/bin/trace

    echo "[✓] Global install complete."
else
    echo "[+] Installing locally (non-root)..."

    TARGET="$HOME/.local/bin/Trace-ip"
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    cp -r ./* "$TARGET/"

    mkdir -p "$HOME/.local/bin"
    mv -f trace "$HOME/.local/bin/trace"
    chmod +x "$HOME/.local/bin/trace"

    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    echo "[✓] Local install complete."
fi

echo ""
echo "[Trace-it] Dependency Checker"
echo "------------------------------------------"

# ===========================================================
# REQUIRED TOOLS
# ===========================================================
REQUIRED_TOOLS=(curl jq dig hostname arp ip nmap iwlist nmcli bluetoothctl)

# ===========================================================
# FUNCTIONS FOR INSTALLING LATEST VERSIONS
# ===========================================================
install_linux() {
    sudo apt update -y
    sudo apt install -y "$@"
}

install_termux() {
    pkg update -y
    pkg upgrade -y
    pkg install -y "$@"
}

install_macos() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "[!] Homebrew missing → installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew update
    brew install "$@"
}

# ===========================================================
# DETECT PLATFORM
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
# CHECK FOR MISSING TOOLS
# ===========================================================
MISSING=()

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING+=("$tool")
    fi
done

if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "[✓] All dependencies already installed!"
else
    echo "Missing tools:"
    for m in "${MISSING[@]}"; do echo " - $m"; done
    echo ""

    case $ENV in
        linux)  echo "[+] Installing missing packages (Linux)..."; install_linux "${MISSING[@]}";;
        termux) echo "[+] Installing missing packages (Termux)..."; install_termux "${MISSING[@]}";;
        macos)  echo "[+] Installing missing packages (macOS)...";  install_macos "${MISSING[@]}";;
        *)      echo "[!] Unsupported OS. Install manually."; exit 1;;
    esac
fi

echo ""
echo "[✓] Setup finished!"
echo "Run Trace-it with: trace"
