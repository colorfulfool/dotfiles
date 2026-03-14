#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/color-schemes/BreezeDark.colors|' ~/.config/qt6ct/qt6ct.conf
