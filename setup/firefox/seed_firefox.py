#!/usr/bin/env python3
import json
import socket
import sys
import time
from pathlib import Path

REMOVED_WIDGETS = ["firefox-view-button"]

SCRIPT = """
const [id, data] = arguments;
const {ExtensionStorageIDB} = ChromeUtils.importESModule("resource://gre/modules/ExtensionStorageIDB.sys.mjs");
for (let i = 0; i < 120 && !WebExtensionPolicy.getByID(id)?.extension; i++) {
  await new Promise(r => setTimeout(r, 500));
}
const ext = WebExtensionPolicy.getByID(id)?.extension;
if (!ext) return false;
const db = await ExtensionStorageIDB.open(ExtensionStorageIDB.getStoragePrincipal(ext));
await db.set(data);
return true;
"""


def main():
    storage = json.loads((Path(__file__).resolve().parent / "extensions_storage.json").read_text())

    for _ in range(120):
        try:
            sock = socket.create_connection(("127.0.0.1", 2828))
            break
        except OSError:
            time.sleep(0.5)
    else:
        sys.exit("Marionette not reachable")
    stream = sock.makefile("rb")
    msg_id = 0

    def recv():
        size = b""
        while (c := stream.read(1)) != b":":
            size += c
        return json.loads(stream.read(int(size)))

    def send(cmd, params):
        nonlocal msg_id
        msg_id += 1
        data = json.dumps([0, msg_id, cmd, params])
        sock.sendall(f"{len(data)}:{data}".encode())
        _, _, error, result = recv()
        if error:
            raise RuntimeError(error)
        return result

    recv()
    send("WebDriver:NewSession", {})
    send("Marionette:SetContext", {"value": "chrome"})
    for ext_id, data in storage.items():
        ok = send("WebDriver:ExecuteScript", {
            "script": f"return (async () => {{ {SCRIPT} }})()",
            "args": [ext_id, data],
            "scriptTimeout": 90000,
        })["value"]
        print(f"{ext_id}: {'ok' if ok else 'not installed'}")
    send("WebDriver:ExecuteScript", {
        "script": "const {CustomizableUI} = ChromeUtils.importESModule('resource:///modules/CustomizableUI.sys.mjs');"
                  "arguments[0].forEach(w => CustomizableUI.removeWidgetFromArea(w));",
        "args": [REMOVED_WIDGETS],
    })
    send("WebDriver:DeleteSession", {})


if __name__ == "__main__":
    main()
