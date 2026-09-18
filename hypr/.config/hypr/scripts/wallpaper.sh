#!/usr/bin/env bash
# Random wallpaper fetcher (internet) + persistence for hyprpaper 0.8.
#
# Usage:
#   wallpaper.sh next     # download a random wallpaper, apply it, remember it
#   wallpaper.sh restore  # re-apply the remembered wallpaper (autostart)
#
# State (two redundant copies, either is enough to recover):
#   remembered path -> $HOME/.local/state/hyprpaper/current-wallpaper
#   hyprpaper.conf  -> wallpaper { path = ... } block (re-read on daemon start)
#   downloads       -> $HOME/Pictures/wallpapers/
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Pictures/wallpapers}"
STATE_DIR="$HOME/.local/state/hyprpaper"
STATE_FILE="$STATE_DIR/current-wallpaper"
CONF="$HOME/.config/hypr/hyprpaper.conf"
FALLBACK="$HOME/.dotfiles/nix/city.jpg"
MAX_KEEP=50

notify() {
  # timeout: notify-send blocks forever when no notification daemon runs.
  if command -v notify-send >/dev/null 2>&1; then
    timeout 2 notify-send "Wallpaper" "$1" >/dev/null 2>&1 || true
  else
    echo "wallpaper: $1"
  fi
}

ensure_hyprpaper() {
  if ! pidof hyprpaper >/dev/null 2>&1; then
    hyprpaper >/dev/null 2>&1 &
  fi
  # Wait for the hyprpaper IPC to come up (max ~5s).
  for _ in $(seq 1 50); do
    if hyprctl hyprpaper listactive >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.1
  done
  echo "wallpaper: hyprpaper IPC did not come up" >&2
  return 1
}

# Keep hyprpaper.conf pointing at the current wallpaper so a daemon
# restart / next login shows it even before `restore` runs.
sync_conf() {
  local img="$1"
  local tmp
  tmp="$(mktemp)"
  awk -v img="$img" '
    /^\s*path\s*=/ { print "    path = " img; next }
    { print }
  ' "$CONF" >"$tmp"
  mv "$tmp" "$CONF"
}

apply_wallpaper() {
  local img="$1"
  ensure_hyprpaper
  sync_conf "$img"
  hyprctl hyprpaper wallpaper ",$img,cover"
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$img" >"$STATE_FILE"
}

cmd_next() {
  mkdir -p "$WALL_DIR"
  local tmp
  tmp="$(mktemp --suffix=.jpg)"
  # shellcheck disable=SC2064
  trap "rm -f '$tmp'" EXIT

  if ! curl -sSL --max-time 30 --retry 2 "https://picsum.photos/seed/$RANDOM/2560/1440" -o "$tmp"; then
    notify "Download failed (offline?) — keeping current wallpaper"
    return 1
  fi
  if ! file --mime-type "$tmp" | grep -q 'image/'; then
    notify "Download failed (bad response) — keeping current wallpaper"
    return 1
  fi

  local dest="$WALL_DIR/wallpaper-$(date +%Y%m%d-%H%M%S).jpg"
  mv "$tmp" "$dest"
  trap - EXIT

  # Keep the cache bounded.
  ls -1t "$WALL_DIR"/wallpaper-*.jpg 2>/dev/null | tail -n +$((MAX_KEEP + 1)) | xargs -r rm -f --

  apply_wallpaper "$dest"
  notify "New wallpaper: $(basename "$dest")"
}

cmd_restore() {
  if [[ -f $STATE_FILE ]]; then
    local saved
    saved="$(cat "$STATE_FILE")"
    if [[ -f $saved ]]; then
      apply_wallpaper "$saved"
      return 0
    fi
  fi
  # First run / deleted state: seed from the newest download, else the old city.jpg.
  local latest
  latest="$(ls -1t "$WALL_DIR"/wallpaper-*.jpg 2>/dev/null | head -n 1 || true)"
  if [[ -n ${latest:-} && -f $latest ]]; then
    apply_wallpaper "$latest"
  elif [[ -f $FALLBACK ]]; then
    apply_wallpaper "$FALLBACK"
  else
    echo "wallpaper: no wallpaper to restore (no state, no downloads, no fallback)" >&2
    return 1
  fi
}

case "${1:-}" in
  next) cmd_next ;;
  restore) cmd_restore ;;
  *)
    echo "Usage: $(basename "$0") {next|restore}" >&2
    exit 1
    ;;
esac
