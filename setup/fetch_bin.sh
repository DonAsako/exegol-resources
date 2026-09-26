#!/bin/bash
# Download drop-on-target binaries into /opt/my-resources/bin (persistent, shared across containers).
# Idempotent: only downloads what's missing. Edit the versions/list below to taste.
set -u

BIN=/opt/my-resources/bin
mkdir -p "$BIN"

PSPY_VER=v1.2.1
LIGOLO_VER=0.8.3   # keep in sync with Exegol's ligolo-ng proxy (ligolo-ng -version)

# name  ->  URL   (plain binaries)
declare -A RAW=(
  [pspy64]="https://github.com/DominicBreuker/pspy/releases/download/$PSPY_VER/pspy64"
  [pspy32]="https://github.com/DominicBreuker/pspy/releases/download/$PSPY_VER/pspy32"
  [pspy64s]="https://github.com/DominicBreuker/pspy/releases/download/$PSPY_VER/pspy64s"
  [pspy32s]="https://github.com/DominicBreuker/pspy/releases/download/$PSPY_VER/pspy32s"
)

# name  ->  URL|member  (archive to extract a single file from)
declare -A ARCHIVE=(
  [ligolo-agent-linux]="https://github.com/nicocha30/ligolo-ng/releases/download/v$LIGOLO_VER/ligolo-ng_agent_${LIGOLO_VER}_linux_amd64.tar.gz|agent"
  [ligolo-agent.exe]="https://github.com/nicocha30/ligolo-ng/releases/download/v$LIGOLO_VER/ligolo-ng_agent_${LIGOLO_VER}_windows_amd64.zip|agent.exe"
)

for name in "${!RAW[@]}"; do
  [[ -f "$BIN/$name" ]] && continue
  echo "fetching $name"
  curl -fsSL "${RAW[$name]}" -o "$BIN/$name" && chmod +x "$BIN/$name" || rm -f "$BIN/$name"
done

tmp=$(mktemp -d)
for name in "${!ARCHIVE[@]}"; do
  [[ -f "$BIN/$name" ]] && continue
  url=${ARCHIVE[$name]%|*}; member=${ARCHIVE[$name]#*|}
  echo "fetching $name"
  f="$tmp/$(basename "$url")"
  curl -fsSL "$url" -o "$f" || continue
  case "$f" in
    *.tar.gz) tar -xzf "$f" -C "$tmp" "$member" ;;
    *.zip)    unzip -o -q "$f" "$member" -d "$tmp" ;;
  esac
  [[ -f "$tmp/$member" ]] && mv "$tmp/$member" "$BIN/$name" && chmod +x "$BIN/$name"
done
rm -rf "$tmp"
