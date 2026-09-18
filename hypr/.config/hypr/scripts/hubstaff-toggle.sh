#!/usr/bin/env bash
# Hubstaff timer toggle via scripted control (HubstaffCLI).
#
# Usage:
#   hubstaff-toggle.sh        # toggle: stop if tracking, resume if stopped
#   hubstaff-toggle.sh status # print raw status JSON
#
# Requires: Hubstaff desktop timer installed at ~/Hubstaff, with
# scripted control allowed (app Preferences -> Allow scripted control).
set -euo pipefail

CLI="$HOME/Hubstaff/HubstaffCLI.bin.x86_64"
REAL_IPC="$HOME/.local/share/Hubstaff/HubstaffCLI.ipc"
CLI_IPC="$HOME/.local/share/HubStaff/HubstaffCLI.ipc"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    timeout 2 notify-send "Hubstaff" "$1" >/dev/null 2>&1 || true
  else
    echo "hubstaff: $1"
  fi
}

# Work around Hubstaff Linux bug: the daemon listens on
# ~/.local/share/Hubstaff/HubstaffCLI.ipc (lowercase 's') while the CLI
# connects to ~/.local/share/HubStaff/HubstaffCLI.ipc (capital 'S').
ensure_ipc() {
  if [[ -e $REAL_IPC && ! -e $CLI_IPC ]]; then
    mkdir -p "$(dirname "$CLI_IPC")"
    ln -sf ../Hubstaff/HubstaffCLI.ipc "$CLI_IPC"
  fi
}

hubstaff_status() {
  ensure_ipc
  "$CLI" status 2>/dev/null
}

if [[ ${1:-} == "status" ]]; then
  hubstaff_status
  exit 0
fi

STATUS="$(hubstaff_status || true)"

if echo "$STATUS" | grep -q '"error"'; then
  notify "Could not connect to timer (is Hubstaff running?)"
  echo "$STATUS" >&2
  exit 1
fi

TRACKING="$(echo "$STATUS" | jq -r '.tracking // empty' 2>/dev/null || true)"
PROJECT="$(echo "$STATUS" | jq -r '.active_project.name // empty' 2>/dev/null || true)"
TASK="$(echo "$STATUS" | jq -r '.active_task.name // empty' 2>/dev/null || true)"
LABEL="$PROJECT"
[[ -n $TASK ]] && LABEL="$PROJECT / $TASK"

if [[ $TRACKING == "true" ]]; then
  OUT="$("$CLI" stop 2>/dev/null || true)"
  notify "Stopped tracking ${LABEL:-timer}"
  echo "$OUT"
else
  OUT="$("$CLI" resume 2>/dev/null || true)"
  if echo "$OUT" | grep -q '"error"'; then
    notify "Resume failed: $OUT"
    echo "$OUT" >&2
    exit 1
  fi
  # Fetch fresh status so the notification names what actually started.
  FRESH="$(hubstaff_status || true)"
  PROJECT="$(echo "$FRESH" | jq -r '.active_project.name // empty' 2>/dev/null || true)"
  TASK="$(echo "$FRESH" | jq -r '.active_task.name // empty' 2>/dev/null || true)"
  LABEL="$PROJECT"
  [[ -n $TASK ]] && LABEL="$PROJECT / $TASK"
  notify "Started tracking ${LABEL:-timer}"
  echo "$OUT"
fi
