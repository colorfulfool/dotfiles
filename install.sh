#!/bin/bash
set -e

# Arch Linux dependencies for dotfiles

packages=(
  # Hyprland desktop
  hyprland
  waybar
  wofi
  hyprpaper
  hypridle
  hyprlock
  hyprshot
  uwsm

  # Terminal
  kitty

  # Shell & prompt
  zsh
  starship
  fzf
  bat
  zoxide
  stow

  # Dev tools
  neovim
  git
  github-cli
  mise

  # LSP servers
  lua-language-server
  tailwindcss-language-server

  # Audio/media/brightness
  pamixer
  playerctl
  brightnessctl

  # System monitor
  btop

  # File management
  nautilus
  xdg-utils
  xdg-desktop-portal
  xdg-desktop-portal-gtk

  # Wayland clipboard
  wl-clipboard

  # Image/video tools
  imagemagick
  ffmpeg
  curl
  libnotify

  # Fonts
  ttf-jetbrains-mono-nerd

  # Qt/KDE theming
  qt6ct

  # GTK/GNOME integration
  glib2

  # Bluetooth/Network
  blueman
  networkmanager

  # AUR/third-party
  omarchy
  better-control
  yin-yang

  # Optional apps
  chromium
  zathura
)

if command -v yay &>/dev/null; then
  aur_helper=yay
elif command -v paru &>/dev/null; then
  aur_helper=paru
else
  echo "No AUR helper found. Install yay or paru first."
  exit 1
fi

$aur_helper -S --needed "${packages[@]}"
