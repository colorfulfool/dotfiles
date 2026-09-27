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
  pipewire-pulse
  gammastep

  # better-control runtime deps (fork installed via `make install` below)
  gtk3
  bluez
  bluez-utils
  python-gobject
  python-dbus
  python-psutil
  python-qrcode
  python-setproctitle
  python-pydbus
  python-requests
  python-pillow
  power-profiles-daemon
  make

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

# better-control: install my fork (PR #172) instead of the AUR package,
# until it gets merged upstream.
# https://github.com/better-ecosystem/better-control/pull/172
BETTER_CONTROL_REPO="https://github.com/colorfulfool/better-control.git"
BETTER_CONTROL_BRANCH="read-tab-from-file"

# `make install` writes to the same paths as the AUR package, so remove
# any AUR-installed version first to avoid file conflicts.
for p in better-control-git better-control; do
  if pacman -Qq "$p" &>/dev/null; then
    $aur_helper -Rns --noconfirm "$p"
  fi
done

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
git clone --depth 1 --branch "$BETTER_CONTROL_BRANCH" "$BETTER_CONTROL_REPO" "$tmp_dir/better-control"
sudo make -C "$tmp_dir/better-control" install
