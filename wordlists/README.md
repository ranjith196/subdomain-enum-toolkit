# Wordlists

Place your subdomain wordlists here.

Recommended downloads:
- Full SecLists: https://github.com/danielmiessler/SecLists
- Best starter: `Discovery/DNS/subdomains-top1million-5000.txt`
- Bigger: `Discovery/DNS/subdomains-top1million-110000.txt`
- Massive: `Discovery/DNS/combined_subdomains.txt`

The `install.sh` creates a small starter wordlist automatically.

To download a good one manually:
```bash
curl -sL "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" -o wordlists/subdomains-top1million-5000.txt
```
