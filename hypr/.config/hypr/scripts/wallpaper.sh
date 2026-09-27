#!/usr/bin/env bash
# Random wallpaper fetcher for swaybg (ARM-safe, no hyprpaper/omarchy bar).
# Usage:
#   wallpaper.sh next     # download random wallpaper, apply via swaybg
#   wallpaper.sh restore  # re-apply remembered wallpaper (autostart)
#
# Downloads -> $HOME/Pictures/wallpapers/
# State     -> $HOME/.local/state/swaybg/current-wallpaper (and hyprpaper compat)
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Pictures/wallpapers}"
STATE_DIR="$HOME/.local/state/swaybg"
STATE_FILE="$STATE_DIR/current-wallpaper"
# keep hyprpaper state in sync for compat if user switches back
HYPR_STATE_DIR="$HOME/.local/state/hyprpaper"
HYPR_STATE_FILE="$HYPR_STATE_DIR/current-wallpaper"
FALLBACK="$HOME/dotfiles/nix/city.jpg"
MAX_KEEP=50

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    timeout 2 notify-send "Wallpaper" "$1" >/dev/null 2>&1 || true
  else
    echo "wallpaper: $1"
  fi
}

apply_wallpaper() {
  local img="$1"
  if [[ ! -f $img ]]; then
    echo "wallpaper: not found: $img" >&2
    return 1
  fi
  if ! command -v swaybg >/dev/null 2>&1; then
    echo "wallpaper: swaybg not installed (pacman -S swaybg)" >&2
    return 1
  fi
  # Kill old swaybg so new one replaces it (swaybg doesn't support reload)
  pkill -x swaybg 2>/dev/null || true
  # Give it a moment to exit before starting new one
  sleep 0.2
  swaybg -i "$img" -m fill >/dev/null 2>&1 &
  # Remember for restore
  mkdir -p "$STATE_DIR" "$HYPR_STATE_DIR"
  printf '%s\n' "$img" >"$STATE_FILE"
  printf '%s\n' "$img" >"$HYPR_STATE_FILE"
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
  ls -1t "$WALL_DIR"/wallpaper-*.jpg 2>/dev/null | tail -n +$((MAX_KEEP + 1)) | xargs -r rm -f --
  apply_wallpaper "$dest"
  notify "New wallpaper: $(basename "$dest")"
}

cmd_restore() {
  # 1. swaybg state
  if [[ -f $STATE_FILE ]]; then
    local saved; saved="$(cat "$STATE_FILE")"
    if [[ -f $saved ]]; then
      apply_wallpaper "$saved"
      return 0
    fi
  fi
  # 2. hyprpaper compat state
  if [[ -f $HYPR_STATE_FILE ]]; then
    local saved; saved="$(cat "$HYPR_STATE_FILE")"
    if [[ -f $saved ]]; then
      apply_wallpaper "$saved"
      return 0
    fi
  fi
  # 3. newest download
  local latest
  latest="$(ls -1t "$WALL_DIR"/wallpaper-*.jpg 2>/dev/null | head -n 1 || true)"
  if [[ -n ${latest:-} && -f $latest ]]; then
    apply_wallpaper "$latest"
    return 0
  fi
  # 4. fallback
  if [[ -f $FALLBACK ]]; then
    apply_wallpaper "$FALLBACK"
    return 0
  fi
  echo "wallpaper: no wallpaper to restore (no state, no downloads, no fallback)" >&2
  return 1
}

case "${1:-}" in
  next) cmd_next ;;
  restore) cmd_restore ;;
  *) echo "Usage: $(basename "$0") {next|restore}" >&2; exit 1 ;;
esac
