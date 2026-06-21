#!/bin/zsh
# Removes auto-quit completely: unloads the agent and deletes all its files.
PLIST="$HOME/Library/LaunchAgents/com.user.autoquit.plist"

launchctl unload "$PLIST" 2>/dev/null || true
launchctl bootout "gui/$(id -u)/com.user.autoquit" 2>/dev/null || true
rm -f "$PLIST"
rm -rf "$HOME/Library/Application Support/auto-quit"
rm -f "$HOME/Library/Logs/auto-quit.log"

echo "auto-quit uninstalled. Nothing left behind."
