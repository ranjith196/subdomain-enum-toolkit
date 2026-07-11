#!/bin/bash

# Subdomain Enumeration Toolkit - Installer
# Simple and beginner friendly

set -e

echo "=============================================="
echo "  Subdomain Enum Toolkit - Installer"
echo "=============================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${YELLOW}[!] Go is not installed. Please install Go first from https://go.dev${NC}"
    echo "After installing Go, re-run this script."
    exit 1
else
    echo -e "${GREEN}[+] Go is already installed${NC}"
fi

export PATH=$PATH:$(go env GOPATH)/bin

echo ""
echo "[*] Installing tools..."

# Install ProjectDiscovery tools
echo "[+] Installing subfinder..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "[+] Installing dnsx..."
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest

echo "[+] Installing httpx..."
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo "[+] Installing shuffledns..."
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest

echo "[+] Installing assetfinder..."
go install -v github.com/tomnomnom/assetfinder@latest

echo "[+] Installing amass (this may take time)..."
go install -v github.com/owasp-amass/amass/v4/...@master || echo "Amass install failed - you can install later"

# Make scripts executable
chmod +x subenum.sh 2>/dev/null || true

# Create directories
mkdir -p results wordlists scripts

# Download a small good wordlist if not present
if [ ! -f wordlists/subdomains-top1million-5000.txt ]; then
    echo "[+] Creating starter wordlist..."
    cat > wordlists/subdomains-top1million-5000.txt << 'EOL'
api
www
mail
dev
staging
test
admin
portal
app
cdn
blog
shop
secure
login
m
mobile
static
assets
img
images
js
css
ftp
smtp
pop
imap
vpn
remote
git
jenkins
ci
beta
alpha
demo
EOL
    echo "[+] Basic wordlist created. Download full SecLists for better results."
fi

echo ""
echo -e "${GREEN}=============================================="
echo "  Installation Complete!"
echo "==============================================${NC}"
echo ""
echo "Next steps:"
echo "1. Add API keys for better results:"
echo "   mkdir -p ~/.config/subfinder"
echo "   nano ~/.config/subfinder/provider-config.yaml"
echo ""
echo "2. Run your first scan:"
echo "   ./subenum.sh -d example.com"
echo ""
echo "Happy Hunting! 🎯"
