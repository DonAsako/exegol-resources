#!/bin/bash

DIR="$(dirname "$(realpath "$0")")"
SEED="$DIR/foxyproxy.json"
POLICY=/usr/lib/firefox-esr/distribution/policies.json

[[ -f "$SEED" && -f "$POLICY" ]] || exit 0

cp "$POLICY" "$POLICY.orig"
jq --slurpfile fp "$SEED" '.policies["3rdparty"].Extensions["foxyproxy@eric.h.jung"] = $fp[0]' "$POLICY.orig" > "$POLICY"

firefox --headless --marionette -remote-allow-system-access &> /dev/null &
ff_pid=$!
for _ in $(seq 120); do
  grep -qas "qbttuispvhi" "$HOME"/.mozilla/firefox/*/storage/default/moz-extension*/idb/*.sqlite* && break
  sleep 1
done
python3 "$DIR/seed_firefox.py"
sleep 3
kill "$ff_pid" 2> /dev/null
wait "$ff_pid" 2> /dev/null

mv "$POLICY.orig" "$POLICY"
