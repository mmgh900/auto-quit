#!/bin/zsh
# Installs auto-quit as a per-user LaunchAgent that runs every 60s.
set -e

STATE_DIR="$HOME/Library/Application Support/auto-quit"
AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST="$AGENT_DIR/com.user.autoquit.plist"
HERE="${0:A:h}"

mkdir -p "$STATE_DIR" "$AGENT_DIR"

cp "$HERE/auto-quit.sh" "$STATE_DIR/auto-quit.sh"
cp "$HERE/control.applescript" "$STATE_DIR/control.applescript"
chmod +x "$STATE_DIR/auto-quit.sh"

# Seed an excludes file the first time so nothing important gets quit.
if [[ ! -f "$STATE_DIR/excludes.txt" ]]; then
  cp "$HERE/excludes.example.txt" "$STATE_DIR/excludes.txt"
fi
echo 1 > "$STATE_DIR/enabled"

# Render the plist with this machine's $HOME and (re)load it.
sed "s|__HOME__|$HOME|g" "$HERE/com.user.autoquit.plist.template" > "$PLIST"
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo "auto-quit installed and loaded."
echo "  edit excludes:  $STATE_DIR/excludes.txt"
echo "  disable:        echo 0 > \"$STATE_DIR/enabled\""
echo "  uninstall:      ./uninstall.sh"
