#!/bin/bash
set -e

# Arch Linux dependencies for dotfiles

packages=(
  # Hyprland desktop
  hyprland
  waybar
  wofi
  swaybg
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
  yin-yang
  breezex-cursor-theme # BreezeX-Black (hyprland.lua, kcminputrc)

  # Optional apps
  chromium
  zathura
)

# Not available on ARM/aarch64 — kept last so they can't break the install above
x86_only=(
  mise
  omarchy
  better-control
)

if command -v yay &>/dev/null; then
  aur_helper=yay
elif command -v paru &>/dev/null; then
  aur_helper=paru
else
  echo "No AUR helper found. Install yay or paru first."
  exit 1
fi

sudo pacman -Syy

$aur_helper -S --needed --noconfirm "${packages[@]}"

for p in "${x86_only[@]}"; do
  $aur_helper -S --needed --noconfirm "$p" || echo "warning: skipping $p (not available on this architecture)"
done
