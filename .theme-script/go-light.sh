#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeLight
# kwriteconfig6 only flips the label; this rewrites the actual [Colors:*] palette
plasma-apply-colorscheme BreezeLight 2>/dev/null || true
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeLight.colors
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
# GTK3/GTK4 (wofi reads these, not gsettings): stop forcing dark.
# plasma-apply-colorscheme can't regenerate GTK colors outside a Plasma
# session, so drop its dark overrides and let system Breeze follow the
# prefer-dark flag (light Breeze = #eff0f1).
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme false
kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme false
rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-3.0/colors.css ~/.config/gtk-3.0/gtk-dark.css ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/colors.css
