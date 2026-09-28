#!/bin/bash
# When KDE switches color scheme, it updates the xdg portal but not gsettings.
# SublimeMerge (and other GTK apps) watch gsettings, not the portal.
# This script bridges the two.

# Same fallback as .theme-script/go-{dark,light}.sh: kwriteconfig6 needs KDE's
# kconfig package, which isn't installed on this Hyprland system.
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

dbus-monitor --session \
    "type='signal',interface='org.freedesktop.portal.Settings',member='SettingChanged',arg0='org.freedesktop.appearance',arg1='color-scheme'" |
while read -r line; do
    if echo "$line" | grep -q 'uint32 1'; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
        plasma-apply-colorscheme BreezeDark 2>/dev/null || true
        kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeDark.colors
        kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
    elif echo "$line" | grep -q 'uint32 2\|uint32 0'; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
        plasma-apply-colorscheme BreezeLight 2>/dev/null || true
        kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeLight.colors
        kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
    fi
done
