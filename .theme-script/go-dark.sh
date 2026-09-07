#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeDark
# kwriteconfig6 only flips the label; this rewrites the actual [Colors:*] palette
plasma-apply-colorscheme BreezeDark 2>/dev/null || true
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeDark.colors
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
rm -f ~/.config/gtk-4.0/gtk.css
