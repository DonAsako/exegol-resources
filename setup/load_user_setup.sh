#!/bin/bash
set -e

# This script will be executed on the first startup of each new container with the "my-resources" feature enabled.
# Arbitrary code can be added in this file, in order to customize Exegol (dependency installation, configuration file copy, etc).
# It is strongly advised **not** to overwrite the configuration files provided by exegol (e.g. /root/.zshrc, /opt/.exegol_aliases, ...), official updates will not be applied otherwise.

# Exegol also features a set of supported customization a user can make.
# The /opt/supported_setups.md file lists the supported configurations that can be made easily.

# Install uv (https://astral.sh/uv)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Set firefox preferences
cp /opt/my-resources/setup/firefox/exegol.cfg /usr/lib/firefox-esr/exegol.cfg
printf 'pref("general.config.filename", "exegol.cfg");\npref("general.config.obscure_value", 0);\n' > /usr/lib/firefox-esr/defaults/pref/autoconfig.js

# Seed Firefox extensions (FoxyProxy Burp proxy, Wappalyzer consent), editable afterwards
/opt/my-resources/setup/firefox/seed_extensions.sh

# Install Burp extensions (BApp Store)
python3 /opt/my-resources/setup/burp/install_bapps.py

# Fetch drop-on-target binaries (pspy, ligolo agents) into bin/
/opt/my-resources/setup/fetch_bin.sh
