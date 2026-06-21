#!/bin/zsh
# Quits apps that haven't been frontmost for IDLE_MINUTES.

IDLE_MINUTES=10
STATE_DIR="$HOME/Library/Application Support/auto-quit"
STATE_FILE="$STATE_DIR/last-seen.tsv"
EXCLUDE_FILE="$STATE_DIR/excludes.txt"
ENABLED_FLAG="$STATE_DIR/enabled"
LOG_FILE="$HOME/Library/Logs/auto-quit.log"
mkdir -p "$STATE_DIR"
touch "$STATE_FILE"

# Honor enable/disable toggle (defaults to enabled if flag missing)
if [[ -f "$ENABLED_FLAG" ]] && [[ "$(cat "$ENABLED_FLAG")" == "0" ]]; then
  exit 0
fi

# Load excludes
typeset -a EXCLUDE
if [[ -f "$EXCLUDE_FILE" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && EXCLUDE+=("$line")
  done < "$EXCLUDE_FILE"
fi

is_excluded() {
  local name="$1"
  for e in "${EXCLUDE[@]}"; do
    [[ "$name" == "$e" ]] && return 0
  done
  return 1
}

NOW=$(date +%s)
IDLE_SEC=$(( IDLE_MINUTES * 60 ))

FRONT=$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true' 2>/dev/null)
RUNNING=$(osascript -e 'tell application "System Events" to get name of (every application process whose background only is false)' 2>/dev/null | tr ',' '\n' | sed 's/^ *//;s/ *$//')

typeset -A LAST
while IFS=$'\t' read -r app ts; do
  [[ -n "$app" ]] && LAST[$app]=$ts
done < "$STATE_FILE"

NEW_STATE=""
while IFS= read -r app; do
  [[ -z "$app" ]] && continue
  if [[ "$app" == "$FRONT" ]]; then
    LAST[$app]=$NOW
  elif [[ -z "${LAST[$app]}" ]]; then
    LAST[$app]=$NOW
  fi

  last_ts=${LAST[$app]}
  age=$(( NOW - last_ts ))

  if (( age >= IDLE_SEC )) && ! is_excluded "$app" && [[ "$app" != "$FRONT" ]]; then
    echo "$(date '+%F %T') quitting '$app' (idle ${age}s)" >> "$LOG_FILE"
    osascript -e "tell application \"$app\" to quit" 2>>"$LOG_FILE"
    unset "LAST[$app]"
    continue
  fi
  NEW_STATE+="$app	$last_ts"$'\n'
done <<< "$RUNNING"

printf '%s' "$NEW_STATE" > "$STATE_FILE"
