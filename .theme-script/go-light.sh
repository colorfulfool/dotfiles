#!/bin/bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
sed -i 's|color_scheme_path=.*|color_scheme_path=/usr/share/color-schemes/BreezeLight.colors|' ~/.config/qt6ct/qt6ct.conf
