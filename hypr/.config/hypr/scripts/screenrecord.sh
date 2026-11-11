#!/bin/bash
# Toggle a fullscreen screen recording with gpu-screen-recorder.
#
# Usage:
#   screenrecord.sh           # start, or stop the recording in progress
#   screenrecord.sh --audio   # include desktop audio (default output)
#
# Recordings -> ${XDG_VIDEOS_DIR:-$HOME/Videos}/screenrecording-<date>.mp4
# State      -> $XDG_RUNTIME_DIR/screenrecord.state (pid on line 1, file on 2)
#
# Works without Hyprland tooling: if hyprctl/jq aren't available the recorder
# falls back to gpu-screen-recorder's own "focused" target.
set -euo pipefail

[[ -f $HOME/.config/user-dirs.dirs ]] && . "$HOME/.config/user-dirs.dirs"
OUT_DIR="${SCREENRECORD_DIR:-${XDG_VIDEOS_DIR:-$HOME/Videos}}"
STATE="${XDG_RUNTIME_DIR:-/tmp}/screenrecord.state"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    timeout 3 notify-send "Screen recording" "$1" >/dev/null 2>&1 || true
  else
    echo "screenrecord: $1"
  fi
}

running_pid() {
  [[ -f $STATE ]] || return 1
  local pid
  read -r pid <"$STATE"
  [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null && echo "$pid"
}

# Stop path: SIGINT (not SIGTERM) is what makes gpu-screen-recorder finalize
# the mp4 instead of leaving a truncated file behind.
if pid="$(running_pid)"; then
  file="$(sed -n 2p "$STATE")"
  kill -INT "$pid"
  for _ in {1..50}; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done
  kill -0 "$pid" 2>/dev/null && kill -9 "$pid"
  rm -f "$STATE"
  notify "Saved ${file:-recording}"
  exit 0
fi

command -v gpu-screen-recorder >/dev/null 2>&1 || {
  notify "gpu-screen-recorder is not installed"
  exit 1
}

audio=()
for arg in "$@"; do
  case "$arg" in
  --audio) audio=(-a default_output -ac aac) ;;
  *)
    echo "Unknown option: $arg" >&2
    exit 1
    ;;
  esac
done

# Prefer the explicit focused monitor; fall back to gsr's own "focused" target
# when hyprctl/jq are missing. || true keeps pipefail from aborting on a
# not-yet-ready Hyprland socket.
target=(-w focused)
if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  monitor="$(
    hyprctl monitors -j 2>/dev/null |
      jq -r '.[] | select(.focused) | .name' 2>/dev/null |
      head -n1 || true
  )"
  [[ -n $monitor ]] && target=(-w "$monitor")
fi

mkdir -p "$OUT_DIR"
file="$OUT_DIR/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"

# nohup execs in place, so $! is gpu-screen-recorder itself; it also keeps the
# recorder alive after the compositor's exec shell is gone.
nohup gpu-screen-recorder \
  "${target[@]}" -s "${SCREENRECORD_RESOLUTION:-0x0}" \
  -k auto -f 60 -fm cfr -fallback-cpu-encoding yes \
  -o "$file" "${audio[@]}" >/dev/null 2>&1 &
pid=$!

# The file appears once capture is live; wait so a failed start is reported
# instead of leaving a "recording" that never wrote anything.
for _ in {1..50}; do
  [[ -f $file ]] && break
  kill -0 "$pid" 2>/dev/null || {
    notify "Could not start recording"
    exit 1
  }
  sleep 0.1
done

printf '%s\n%s\n' "$pid" "$file" >"$STATE"
notify "Recording ${file##*/}"
