# 🔍 Subdomain Enumeration Toolkit

**Beginner-friendly automated subdomain enumeration toolkit** for Bug Bounty Hunters & Penetration Testers.

Inspired by top GitHub projects:
- [projectdiscovery/subfinder](https://github.com/projectdiscovery/subfinder) (14k+ ⭐) - Fast passive enumeration
- [owasp-amass/amass](https://github.com/owasp-amass/amass) (14k+ ⭐) - In-depth attack surface mapping
- [aboul3la/Sublist3r](https://github.com/aboul3la/Sublist3r) (11k+ ⭐)
- [tomnomnom/assetfinder](https://github.com/tomnomnom/assetfinder)
- [projectdiscovery/shuffledns](https://github.com/projectdiscovery/shuffledns) + massdns

Perfect for beginners who want a clean, working setup without complexity.

---

## ✨ Features

- One-command passive + active subdomain enumeration
- Combines multiple top tools for maximum coverage
- Automatic DNS resolution & wildcard filtering
- Clean output (TXT + JSON)
- Wordlist support for bruteforce
- Easy installation script
- Simple English documentation (great for non-native speakers)

---

## 📦 Tools Used

| Tool | Purpose | Source |
|------|---------|--------|
| **Subfinder** | Fast passive enumeration | ProjectDiscovery |
| **Amass** | Deep passive + active | OWASP |
| **Assetfinder** | Additional passive sources | tomnomnom |
| **dnsx / shuffledns** | Fast resolution + brute | ProjectDiscovery |
| **httprobe / httpx** | Live host detection | ProjectDiscovery / tomnomnom |

---

## 🚀 Quick Start (5 minutes)

### 1. Clone this repository
```bash
git clone https://github.com/ranjith196/subdomain-enum-toolkit.git
cd subdomain-enum-toolkit
```

### 2. Install everything (recommended)
```bash
chmod +x install.sh
./install.sh
```

This installs:
- Go (if missing)
- Subfinder, Amass, Assetfinder, dnsx, httpx, shuffledns
- Required wordlists

### 3. Run enumeration
```bash
# Simple passive scan
./subenum.sh -d example.com

# Full scan (passive + brute force)
./subenum.sh -d example.com -b

# Multiple domains
./subenum.sh -dL domains.txt -b
```

### 4. Results
Results will be saved in `results/example.com/`:
- `all_subdomains.txt` - All unique subdomains
- `live_subdomains.txt` - Only live ones
- `resolved.txt` - With IPs
- Individual tool outputs

---

## 📖 Usage

```bash
./subenum.sh [options]

Options:
  -d, --domain     Target domain (required if no -dL)
  -dL, --list      File with list of domains
  -b, --brute      Enable bruteforce mode (uses wordlist)
  -w, --wordlist   Custom wordlist (default: wordlists/subdomains-top1million-5000.txt)
  -o, --output     Output directory (default: results/)
  -t, --threads    Number of threads (default: 50)
  -s, --silent     Silent mode (only final results)
  -h, --help       Show help
```

### Examples

```bash
# Basic
./subenum.sh -d target.com

# With bruteforce (recommended for better results)
./subenum.sh -d target.com -b

# Custom wordlist + threads
./subenum.sh -d target.com -b -w wordlists/big.txt -t 100

# List of targets
echo "target1.com" > targets.txt
echo "target2.com" >> targets.txt
./subenum.sh -dL targets.txt -b
```

---

## 📁 Project Structure

```
subdomain-enum-toolkit/
├── subenum.sh              # Main automation script
├── install.sh              # One-click installer
├── wordlists/
│   └── README.md
├── results/                # All scan results go here (gitignored)
├── .gitignore
├── LICENSE
└── README.md
```

---

## ⚙️ Configuration (API Keys for better results)

Create provider config for Subfinder:

```bash
mkdir -p ~/.config/subfinder
nano ~/.config/subfinder/provider-config.yaml
```

Example content (get free API keys):
```yaml
securitytrails: ["YOUR_KEY"]
shodan: ["YOUR_KEY"]
virustotal: ["YOUR_KEY"]
censys: ["YOUR_ID:YOUR_SECRET"]
github: ["YOUR_TOKEN"]
```

Then run: `subfinder -up`

---

## 🛠️ Manual Installation (if install.sh fails)

```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/owasp-amass/amass/v4/...@master
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
```

Make sure `$GOPATH/bin` is in your PATH.

---

## 💡 Tips for Better Results

1. **Always use `-b`** for bruteforce on important targets
2. Add API keys (biggest improvement)
3. Use good wordlists from SecLists
4. Run on a VPS for speed and to avoid rate limits
5. Pipe results to `httpx` for live web apps and tech detection

---

## 📜 Disclaimer

This tool is for **authorized security testing and educational purposes only**.  
Do not use against systems without permission. The author is not responsible for any misuse.

---

## 🤝 Credits

- ProjectDiscovery team (Subfinder, dnsx, httpx, shuffledns)
- OWASP Amass
- tomnomnom (assetfinder)
- All open-source contributors who made these tools

---

## 📄 License

MIT License - feel free to use and modify.

---

**Happy Hunting!** 🎯

Created for the community by [Ranjith Kumar](https://github.com/ranjith196)  
If this helped you, give it a ⭐!
