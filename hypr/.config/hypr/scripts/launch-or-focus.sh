#!/bin/bash
# Focus an existing window, or launch the app if none is open.
#
# Usage:
#   launch-or-focus.sh <window-pattern> [command...]
#   launch-or-focus.sh lollypop
#   launch-or-focus.sh chromium chromium --app=https://example.com
#
# The pattern is matched case-insensitively against the window class and title
# (plain substring, not regex). Without a command, the pattern is treated as
# the binary to launch.
#
# Degrades instead of failing when the pieces aren't there: no hyprctl/jq (not
# running under Hyprland, or called before the socket exists) just launches,
# and no uwsm/setsid just runs the command in the background.
set -euo pipefail

if (($# == 0)); then
  echo "Usage: ${0##*/} <window-pattern> [command...]" >&2
  exit 1
fi

pattern="${1,,}"
shift
(($#)) || set -- "$pattern"

launch() {
  if command -v uwsm-app >/dev/null 2>&1; then
    set -- uwsm-app -- "$@"
  fi
  if command -v setsid >/dev/null 2>&1; then
    setsid "$@" >/dev/null 2>&1 &
  else
    "$@" >/dev/null 2>&1 &
  fi
}

address=""
if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  # || true: pipefail would otherwise abort the script when hyprctl has no
  # socket yet or head closes the pipe early, and the app would never start.
  address="$(
    hyprctl clients -j 2>/dev/null |
      jq -r --arg p "$pattern" \
        '.[] | select((.class | ascii_downcase | contains($p)) or (.title | ascii_downcase | contains($p))) | .address' 2>/dev/null |
      head -n1 || true
  )"
fi

if [[ -n $address ]] && hyprctl dispatch focuswindow "address:$address" >/dev/null 2>&1; then
  exit 0
fi

launch "$@"
