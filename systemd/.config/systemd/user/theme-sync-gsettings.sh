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
    elif echo "$line" | grep -q 'uint32 2\|uint32 0'; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
    fi
done
