#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeDark
# kwriteconfig6 only flips the label; this rewrites the actual [Colors:*] palette
plasma-apply-colorscheme BreezeDark 2>/dev/null || true
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeDark.colors
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
# GTK3/GTK4 (wofi reads these, not gsettings): force dark.
# plasma-apply-colorscheme can't regenerate GTK colors outside a Plasma
# session, so drop its overrides and let system Breeze-Dark follow the
# prefer-dark flag.
kwriteconfig6 --file ~/.config/gtk-3.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme true
kwriteconfig6 --file ~/.config/gtk-4.0/settings.ini --group Settings --key gtk-application-prefer-dark-theme true
rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-3.0/colors.css ~/.config/gtk-3.0/gtk-dark.css ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/colors.css
