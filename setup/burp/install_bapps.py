#!/usr/bin/env python3
# Install the latest version of each BApp listed in bapps.txt, the same way the BApp Store does:
# extracted in ~/.BurpSuite/bapps/<uuid>/ and declared in ~/.BurpSuite/UserConfigCommunity.json.
import io
import json
import re
import urllib.request
import zipfile
from pathlib import Path

BAPPS_DIR = Path.home() / ".BurpSuite" / "bapps"
USER_CONFIG = Path.home() / ".BurpSuite" / "UserConfigCommunity.json"


def fetch(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})) as r:
        return r.read()


def install(uuid):
    page = fetch(f"https://portswigger.net/bappstore/{uuid}").decode()
    url = re.search(rf"https://portswigger\.net/bappstore/bapps/download/{uuid}/\d+", page).group(0)
    bapp = zipfile.ZipFile(io.BytesIO(fetch(url)))
    manifest = dict(line.split(": ", 1) for line in bapp.read("BappManifest.bmf").decode().splitlines() if ": " in line)
    dest = BAPPS_DIR / uuid
    bapp.extractall(dest)
    return {
        "bapp_serial_version": int(manifest["SerialVersion"]),
        "bapp_uuid": uuid,
        "errors": "ui",
        "extension_file": str(dest / manifest["EntryPoint"]),
        "extension_type": "java",
        "loaded": True,
        "name": manifest["Name"],
        "output": "ui",
    }


def main():
    uuids = [line.split()[0] for line in (Path(__file__).resolve().parent / "bapps.txt").read_text().splitlines()
             if line.strip() and not line.startswith("#")]
    config = json.loads(USER_CONFIG.read_text()) if USER_CONFIG.exists() else {}
    extensions = config.setdefault("user_options", {}).setdefault("extender", {}).setdefault("extensions", [])
    for uuid in uuids:
        try:
            entry = install(uuid)
        except Exception as e:
            print(f"{uuid}: failed ({e})")
            continue
        extensions[:] = [e for e in extensions if e.get("bapp_uuid") != uuid] + [entry]
        print(f"{entry['name']}: installed")
    USER_CONFIG.parent.mkdir(parents=True, exist_ok=True)
    USER_CONFIG.write_text(json.dumps(config, indent=4))


if __name__ == "__main__":
    main()
