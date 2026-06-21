# auto-quit

A tiny macOS LaunchAgent that **quits apps you haven't used in a while**, to keep
RAM and battery in check. Every 60 seconds it checks which apps are running, tracks
when each was last frontmost, and quits any that have been idle past a threshold
(default **10 minutes**) — unless they're on your exclude list.

It quits apps *gracefully* (`tell application "X" to quit`), so they get to save and
close normally. Browsers, editors, and anything you list in `excludes.txt` are never
touched.

## Install

```sh
git clone https://github.com/mmgh900/auto-quit.git
cd auto-quit
./install.sh
```

This copies the scripts to `~/Library/Application Support/auto-quit/`, seeds an
`excludes.txt` from `excludes.example.txt`, and loads the LaunchAgent (runs at login
and every 60s thereafter).

## Configure

- **Exclude apps:** edit `~/Library/Application Support/auto-quit/excludes.txt` — one
  process name per line (as shown in Activity Monitor).
- **Idle threshold:** change `IDLE_MINUTES` near the top of `auto-quit.sh`
  (then re-run `./install.sh`).
- **Enable / disable** without uninstalling:
  ```sh
  echo 0 > "$HOME/Library/Application Support/auto-quit/enabled"   # off
  echo 1 > "$HOME/Library/Application Support/auto-quit/enabled"   # on
  ```
- **Control panel:** `osascript control.applescript` opens a small dialog to toggle
  on/off and edit exclusions.
- **Log:** `~/Library/Logs/auto-quit.log` records every app it quits.

## Uninstall

```sh
./uninstall.sh
```

Unloads the agent and deletes everything (scripts, plist, state, log) — no leftovers.

## Files

| file | purpose |
|------|---------|
| `auto-quit.sh` | the worker — runs every 60s, quits idle apps |
| `control.applescript` | small GUI to enable/disable and edit excludes |
| `com.user.autoquit.plist.template` | LaunchAgent definition (`__HOME__` is filled in on install) |
| `excludes.example.txt` | starter exclude list |
| `install.sh` / `uninstall.sh` | set up / tear down |

## License

MIT
