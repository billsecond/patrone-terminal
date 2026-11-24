#!/bin/bash
# Runs the installed Flatpak (.github/workflows/flatpak.yml): a command run
# in it runs on the computer, with the terminal's TERM and VTE_VERSION.
set -euo pipefail
id=org.patrone.Terminal
out=$HOME/terminal-flatpak-test.txt
rm -f "$out"
# GTK needs a display: a virtual X server
timeout 60 xvfb-run -a dbus-run-session -- flatpak run "$id" \
    -e sh -c 'echo "$TERM $VTE_VERSION $(cat /etc/os-release | grep ^ID=)" > "$HOME/terminal-flatpak-test.txt"' || true
cat "$out"
grep -q '^xterm-256color [0-9][0-9]* ID=' "$out"
# Ran on the computer: the sandbox's os-release is the runtime's
grep -q 'ID=ubuntu' "$out"
[[ $(flatpak run --command=fc-list "$id" | grep -c PatroneOS) -gt 0 ]]
flatpak run --command=ls "$id" /app/share/doc/patrone-terminal/third-party-licenses.txt.gz \
    /app/share/metainfo/org.patrone.Terminal.metainfo.xml
# VTE's licences, which flatpak-builder records
flatpak run --command=sh "$id" -c 'find /app/share/licenses -name "COPYING.LGPL3*" | grep .'
echo "The Flatpak runs the computer's shell, with its fonts and licences."
