#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeLight
# kwriteconfig6 only flips the label; this rewrites the actual [Colors:*] palette
plasma-apply-colorscheme BreezeLight 2>/dev/null || true
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key color_scheme_path /usr/share/color-schemes/BreezeLight.colors
kwriteconfig6 --file ~/.config/qt6ct/qt6ct.conf --group Appearance --key custom_palette false
rm -f ~/.config/gtk-4.0/gtk.css
