#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
kwriteconfig6 --file ~/.config/kdeglobals --group General --key ColorScheme BreezeLight
rm -f ~/.config/gtk-4.0/gtk.css
