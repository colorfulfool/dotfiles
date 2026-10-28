#!/bin/bash
set -u

mode=dark
if [[ -r "$HOME/.cache/quickshell-mode" ]]; then
  read -r mode < "$HOME/.cache/quickshell-mode"
fi
[[ $mode == light ]] || mode=dark

colors="$HOME/.cache/mako-theme"

if [[ $mode == light ]]; then
  cat >"$colors" <<'EOF'
background-color=#ffffffee
text-color=#000000ff
border-color=#d5d5d5ff
progress-color=over #8a8f98ff
EOF
else
  cat >"$colors" <<'EOF'
background-color=#181818e6
text-color=#ffffffff
border-color=#3a3a3aff
progress-color=over #585b70ff
EOF
fi

if [[ ${1:-} == --start ]]; then
  shift
  exec uwsm-app -- mako "$@"
fi

makoctl reload >/dev/null 2>&1 || true
