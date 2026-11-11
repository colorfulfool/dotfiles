#!/usr/bin/env bash
# Focus an existing window, or launch the app if none is open.
#
# Usage:
#   launch-or-focus.sh <window-pattern> [command...]
#   launch-or-focus.sh lollypop uwsm-app -- lollypop
#
# The pattern is matched case-insensitively against the window class and
# title (plain substring, not regex). Without a command, the pattern is
# treated as the binary to launch through uwsm.
set -euo pipefail

if (($# == 0)); then
  echo "Usage: ${0##*/} <window-pattern> [command...]" >&2
  exit 1
fi

pattern="${1,,}"
shift
(($#)) || set -- uwsm-app -- "$pattern"

address="$(
  hyprctl clients -j |
    jq -r --arg p "$pattern" \
      '.[] | select((.class | ascii_downcase | contains($p)) or (.title | ascii_downcase | contains($p))) | .address' |
    head -n1
)"

if [[ -n $address ]]; then
  hyprctl dispatch focuswindow "address:$address" >/dev/null
else
  setsid "$@" >/dev/null 2>&1 &
fi
