#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeLight
kwriteconfig6 --file ~/.config/kdeglobals --group Icons --key Theme breeze
# kwriteconfig6 only flips the label; merge the real [Colors:*] palette.
# plasma-apply-colorscheme can't do it: it crashes outside a Plasma session.
python3 - <<'EOF'
import configparser
src = configparser.RawConfigParser()
src.optionxform = str
src.read("/usr/share/color-schemes/BreezeLight.colors", encoding="utf-8")
dst = configparser.RawConfigParser()
dst.optionxform = str
p = __import__("os").path.expanduser("~/.config/kdeglobals")
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
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeLight.colors
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
# GTK3/GTK4 (wofi reads these, not gsettings): stop forcing dark.
# plasma-apply-colorscheme can't regenerate GTK colors outside a Plasma
# session, so drop its dark overrides and let system Breeze follow the
# prefer-dark flag (light Breeze = #eff0f1).
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme false
kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme false
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-theme-name Breeze
kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-theme-name Breeze
rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-3.0/colors.css ~/.config/gtk-3.0/gtk-dark.css ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/colors.css
printf 'light\n' > ~/.cache/quickshell-mode
kwriteconfig6 --file ~/.config/qs-env/kdeglobals --group Icons --key Theme breeze
if pgrep -x quickshell >/dev/null 2>&1; then
  pkill -x quickshell
  sleep 0.5
  if command -v uwsm-app >/dev/null 2>&1; then
    uwsm-app -- quickshell >/dev/null 2>&1 &
  else
    quickshell >/dev/null 2>&1 &
  fi
  disown 2>/dev/null || true
fi
