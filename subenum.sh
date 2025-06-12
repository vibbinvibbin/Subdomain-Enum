#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:?Usage: $0 example.com}"
OUTDIR="output/$DOMAIN"
mkdir -p "$OUTDIR"

echo "[*] Passive Enumeration"
subfinder -d "$DOMAIN" -silent -o "$OUTDIR/passive.txt"

#echo "[*] Active Bruteforce"
#puredns bruteforce wordlists/subdomains.txt "$DOMAIN" -r wordlists/resolvers.txt -w "$OUTDIR/active.txt"

echo "[*] Merge & Deduplicate"

if [ -f "$OUTDIR/active.txt" ]; then
  cat "$OUTDIR/passive.txt" "$OUTDIR/active.txt" | sort -u > "$OUTDIR/all.txt"
else
  echo "[!] Skipping active results — only passive found"
  cp "$OUTDIR/passive.txt" "$OUTDIR/all.txt"
fi

echo "[*] DNS Validation with dnsx"
dnsx -silent -l "$OUTDIR/all.txt" -r wordlists/resolvers.txt -o "$OUTDIR/resolved.txt"

echo "[+] Subdomain enumeration complete. Results saved in $OUTDIR"
