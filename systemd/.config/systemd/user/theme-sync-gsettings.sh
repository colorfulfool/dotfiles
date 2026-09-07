#!/bin/bash
# When KDE switches color scheme, it updates the xdg portal but not gsettings.
# SublimeMerge (and other GTK apps) watch gsettings, not the portal.
# This script bridges the two.

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
