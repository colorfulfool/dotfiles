#!/bin/bash
# kwriteconfig6 ships with KDE's kconfig package, which isn't installed on
# this Hyprland system. Fall back to a small python writer supporting the
# same --file/--group/--key subset so the script keeps working (and keeps
# creating parent dirs) instead of failing with "command not found".
if ! command -v kwriteconfig6 >/dev/null 2>&1; then
kwriteconfig6() {
  local file="" group="" key="" val=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --file) file="$2"; shift 2;;
      --group) group="$2"; shift 2;;
      --key) key="$2"; shift 2;;
      *) val="$1"; shift;;
    esac
  done
  if [ -z "$file" ] || [ -z "$group" ] || [ -z "$key" ]; then
    echo "kwriteconfig6 shim: missing --file/--group/--key" >&2; return 1
  fi
  case "$file" in "~"*) file="$HOME${file#\~}";; esac
  mkdir -p "$(dirname "$file")"
  FILE="$file" GROUP="$group" KEY="$key" VALUE="$val" python3 - <<'EOF'
import configparser, os
p = os.path.expanduser(os.environ["FILE"])
c = configparser.RawConfigParser()
c.optionxform = str
c.read(p, encoding="utf-8")
if not c.has_section(os.environ["GROUP"]):
    c.add_section(os.environ["GROUP"])
c.set(os.environ["GROUP"], os.environ["KEY"], os.environ.get("VALUE", ""))
with open(p, "w", encoding="utf-8") as f:
    c.write(f)
EOF
}
fi
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeDark
kwriteconfig6 --file ~/.config/kdeglobals --group Icons --key Theme breeze-dark
# kwriteconfig6 only flips the label; merge the real [Colors:*] palette.
# plasma-apply-colorscheme can't do it: it crashes outside a Plasma session.
# Skip (without touching kdeglobals) when the Breeze palette isn't installed.
python3 - <<'EOF'
import configparser, os
src_path = "/usr/share/color-schemes/BreezeDark.colors"
if not os.path.exists(src_path):
    print(f"skip: {src_path} not installed, leaving ~/.config/kdeglobals palette as-is")
else:
    src = configparser.RawConfigParser()
    src.optionxform = str
    src.read(src_path, encoding="utf-8")
    dst = configparser.RawConfigParser()
    dst.optionxform = str
    p = os.path.expanduser("~/.config/kdeglobals")
    dst.read(p, encoding="utf-8")
    for sec in src.sections():
        if sec.startswith("Colors") or sec.startswith("ColorEffects"):
            if not dst.has_section(sec):
                dst.add_section(sec)
            for k, v in src.items(sec):
                dst.set(sec, k, v)
    with open(p, "w", encoding="utf-8") as f:
        dst.write(f)
EOF
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeDark.colors
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
# GTK3/GTK4 (wofi reads these, not gsettings): force dark.
# plasma-apply-colorscheme can't regenerate GTK colors outside a Plasma
# session, so drop its overrides and let system Breeze-Dark follow the
# prefer-dark flag.
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name Breeze-Dark
kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-theme-name Breeze-Dark
rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-3.0/colors.css ~/.config/gtk-3.0/gtk-dark.css ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/colors.css
printf 'dark\n' > ~/.cache/quickshell-mode
kwriteconfig6 --file ~/.config/qs-env/kdeglobals --group Icons --key Theme breeze-dark
# foot doesn't watch gsettings or the portal: switch running instances
# explicitly. SIGUSR1 = dark ([colors-dark]), SIGUSR2 = light. See foot(1).
command -v pkill >/dev/null 2>&1 && pkill -USR1 foot 2>/dev/null || true
# Herdr never answers DECRPM 2031 or forwards color-scheme changes, so the
# mode-2031/997 auto theme in claude/opencode can't update live inside herdr.
# Raw `\e[?997;Ps n` injection is ignored by those apps. nvim is fixable:
# force its background variable; it re-picks the matching colorscheme.
(
  sleep 0.8
  command -v herdr >/dev/null 2>&1 || exit 0
  for _pass in 1 2; do
    panes=$(herdr pane list 2>/dev/null | python3 -c 'import json,sys
for p in json.load(sys.stdin).get("result", {}).get("panes", []):
    print(p["pane_id"])') || break
    for _pane in $panes; do
      fg=$(herdr pane process-info --pane "$_pane" 2>/dev/null | python3 -c 'import json,sys
try:
    procs = json.load(sys.stdin)["result"]["process_info"]["foreground_processes"]
    print(" ".join(p["name"] for p in procs))
except Exception:
    pass')
      case "$fg" in
        *nvim*)
          herdr pane send-keys "$_pane" escape >/dev/null 2>&1 || true
          herdr pane send-text "$_pane" ":set background=dark" >/dev/null 2>&1 || true
          herdr pane send-keys "$_pane" Return >/dev/null 2>&1 || true
          ;;
      esac
    done
    sleep 1.5
  done
) >/dev/null 2>&1 &
