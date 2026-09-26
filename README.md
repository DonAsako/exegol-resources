# Exegol my-resources

My [Exegol](https://github.com/ThePorgs/Exegol) `my-resources` folder, applied on the first start of each new container.

```bash
git clone https://github.com/DonAsako/exegol-resources.git ~/.exegol/my-resources
```

## uv

[uv](https://docs.astral.sh/uv/) is installed by `setup/load_user_setup.sh`.

## Firefox

Extensions (force-installed, pinned to the toolbar):

- FoxyProxy, with a `Burp` proxy on `127.0.0.1:8080`; Mozilla, DuckDuckGo, trackers and Google Fonts never go through Burp
- Cookie-Editor, ads disabled and advanced options enabled
- Wappalyzer, tracking disabled
- HackTools

Bookmarks for local services: BloodHound-CE, CyberChef, Burp CA.

Settings:

- `.htb`, `.thm`, `.lab`, `.local` open as sites instead of searches
- HTTPS-First and DNS-over-HTTPS disabled
- `localhost` can be proxied through Burp
- DevTools logs persist across navigations
- Telemetry, suggestions, password manager and most prompts disabled

Files, in `setup/firefox/`:

- `policies.json`: Firefox policy, deployed by Exegol
- `exegol.cfg`: prefs that policies can't set, installed as autoconfig by `load_user_setup.sh`
- `seed_extensions.sh`: runs Firefox once headless to write the default config of the extensions (`foxyproxy.json`, `extensions_storage.json`). Everything stays editable afterwards.

## Burp Suite

Extensions from the BApp Store, installed at their latest version: JWT Editor, Hackvertor, InQL, Param Miner, MCP Server.

Files, in `setup/burp/`:

- `bapps.txt`: extensions to install (BApp Store UUIDs)
- `install_bapps.py`: installs them like the BApp Store does, run by `load_user_setup.sh`
