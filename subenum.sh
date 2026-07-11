#!/bin/bash

# ============================================
# Subdomain Enumeration Toolkit
# Simple • Fast • Beginner Friendly
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
DOMAIN=""
DOMAIN_LIST=""
BRUTE=false
WORDLIST="wordlists/subdomains-top1million-5000.txt"
OUTPUT_DIR="results"
THREADS=50
SILENT=false

# Banner
banner() {
    echo -e "${BLUE}"
    cat << "EOF"
 ____        _     _____
/ ___| _   _| |__ | ____|_ __  _   _ _ __ ___
\___ \| | | | '_ \|  _| | '_ \| | | | '_ ` _ \
 ___) | |_| | |_) | |___| | | | |_| | | | | | |
|____/ \__,_|_.__/|_____|_| |_|\__,_|_| |_| |_|

   Subdomain Enumeration Toolkit v1.0
   Powered by Subfinder + Amass + Assetfinder
EOF
    echo -e "${NC}"
}

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -d, --domain     Target domain (e.g. example.com)"
    echo "  -dL, --list      File containing list of domains"
    echo "  -b, --brute      Enable DNS bruteforce"
    echo "  -w, --wordlist   Custom wordlist path"
    echo "  -o, --output     Output directory (default: results)"
    echo "  -t, --threads    Threads for resolution (default: 50)"
    echo "  -s, --silent     Silent mode"
    echo "  -h, --help       Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 -d example.com"
    echo "  $0 -d example.com -b"
    echo "  $0 -dL domains.txt -b -t 100"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -dL|--list)
            DOMAIN_LIST="$2"
            shift 2
            ;;
        -b|--brute)
            BRUTE=true
            shift
            ;;
        -w|--wordlist)
            WORDLIST="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -s|--silent)
            SILENT=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

if [ -z "$DOMAIN" ] && [ -z "$DOMAIN_LIST" ]; then
    banner
    echo -e "${RED}[!] Error: You must provide -d or -dL${NC}"
    usage
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to run for one domain
run_enum() {
    local target=$1
    local out_dir="$OUTPUT_DIR/$target"
    mkdir -p "$out_dir"

    if [ "$SILENT" = false ]; then
        echo -e "${GREEN}[+] Starting enumeration for: $target${NC}"
        echo -e "${YELLOW}[*] Output folder: $out_dir${NC}"
    fi

    # 1. Subfinder (passive)
    if command -v subfinder &> /dev/null; then
        if [ "$SILENT" = false ]; then echo -e "${BLUE}[*] Running Subfinder...${NC}"; fi
        subfinder -d "$target" -silent -o "$out_dir/subfinder.txt" 2>/dev/null || true
    fi

    # 2. Assetfinder
    if command -v assetfinder &> /dev/null; then
        if [ "$SILENT" = false ]; then echo -e "${BLUE}[*] Running Assetfinder...${NC}"; fi
        assetfinder --subs-only "$target" > "$out_dir/assetfinder.txt" 2>/dev/null || true
    fi

    # 3. Amass (passive only for speed)
    if command -v amass &> /dev/null; then
        if [ "$SILENT" = false ]; then echo -e "${BLUE}[*] Running Amass (passive)...${NC}"; fi
        amass enum -passive -d "$target" -o "$out_dir/amass.txt" 2>/dev/null || true
    fi

    # Combine all passive results
    cat "$out_dir"/*.txt 2>/dev/null | sort -u > "$out_dir/all_passive.txt"
    local passive_count=$(wc -l < "$out_dir/all_passive.txt" | tr -d ' ')

    if [ "$SILENT" = false ]; then
        echo -e "${GREEN}[+] Passive found: $passive_count subdomains${NC}"
    fi

    # 4. Bruteforce if enabled
    if [ "$BRUTE" = true ]; then
        if [ -f "$WORDLIST" ]; then
            if [ "$SILENT" = false ]; then echo -e "${BLUE}[*] Running DNS bruteforce with wordlist...${NC}"; fi
            
            if command -v dnsx &> /dev/null; then
                while read -r sub; do
                    echo "${sub}.${target}"
                done < "$WORDLIST" | dnsx -silent -t "$THREADS" -o "$out_dir/brute.txt" 2>/dev/null || true
            fi
        else
            echo -e "${YELLOW}[!] Wordlist not found: $WORDLIST${NC}"
        fi
    fi

    # Combine everything
    cat "$out_dir/all_passive.txt" "$out_dir/brute.txt" 2>/dev/null | sort -u > "$out_dir/all_subdomains.txt"
    local total=$(wc -l < "$out_dir/all_subdomains.txt" | tr -d ' ')

    # Resolve and get live
    if command -v dnsx &> /dev/null; then
        if [ "$SILENT" = false ]; then echo -e "${BLUE}[*] Resolving subdomains...${NC}"; fi
        dnsx -l "$out_dir/all_subdomains.txt" -silent -a -resp -o "$out_dir/resolved.txt" -t "$THREADS" 2>/dev/null || true
        cat "$out_dir/resolved.txt" | cut -d' ' -f1 | sort -u > "$out_dir/live_subdomains.txt"
    else
        cp "$out_dir/all_subdomains.txt" "$out_dir/live_subdomains.txt"
    fi

    local live=$(wc -l < "$out_dir/live_subdomains.txt" 2>/dev/null | tr -d ' ' || echo 0)

    # HTTP probe for live web
    if command -v httpx &> /dev/null; then
        if [ "$SILENT" = false ]; then echo -e "${BLUE}[*] Checking live HTTP services...${NC}"; fi
        httpx -l "$out_dir/live_subdomains.txt" -silent -status-code -title -tech-detect -o "$out_dir/httpx.txt" 2>/dev/null || true
    fi

    if [ "$SILENT" = false ]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}  Results for $target${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo -e "  Total unique subdomains : $total"
        echo -e "  Live (resolved)         : $live"
        echo -e "  Output folder           : $out_dir"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo "Files created:"
        ls -1 "$out_dir"
    fi
}

# Main
banner

if [ -n "$DOMAIN" ]; then
    run_enum "$DOMAIN"
elif [ -n "$DOMAIN_LIST" ]; then
    if [ ! -f "$DOMAIN_LIST" ]; then
        echo -e "${RED}[!] Domain list file not found: $DOMAIN_LIST${NC}"
        exit 1
    fi
    while read -r domain; do
        domain=$(echo "$domain" | tr -d '[:space:]')
        if [ -n "$domain" ]; then
            run_enum "$domain"
        fi
    done < "$DOMAIN_LIST"
fi

echo -e "${GREEN}[✓] All done! Happy hunting 🎯${NC}"
