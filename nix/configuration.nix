{ config, pkgs, lib, ... }:

let
  dotfiles = pkgs.fetchgit {
    url = "https://github.com/colorfulfool/dotfiles.git";
    rev = "f841657";
    hash = "sha256-pvxS7S1XRO5rjViZ2anpV5tHtJPYp+iPz2jVd2uYH78=";
    leaveDotGit = true;
  };
  scripts = pkgs.fetchgit {
    url = "https://github.com/colorfulfool/scripts.git";
    rev = "9b17269";
    hash = "sha256-J06xdlgHO24WiWFmHHZZHKVctV82371YBCF2FKQqPC4=";
  };
  cursors = pkgs.fetchurl {
    url = "https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.1/BreezeX-Black.tar.xz";
    hash = "sha256-dzt1UjdIFzQJ7mIoQbD3Sx6AYXpcWz3LtTp6w9BswjM=";
  };
  wallpaper = "/home/nixos/wallpapers/city.jpg";  # Path in live environment
in

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>
  ];

  # Enable graphical services and Wayland
  services.xserver.enable = true;

  # Use SDDM as display manager with Wayland support
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  programs.hyprland.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.zsh.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"
  ];

  # Install requested packages
  environment.systemPackages = with pkgs; [
    waybar
    wofi
    kitty
    zellij
    nerd-fonts.jetbrains-mono
    hyprpaper # wallpaper (hyprland.lua launches hyprpaper)
    stow
    mise
    git
    gh # GitHub CLI
    starship # prompt (zsh init)
    fzf # fuzzy finder (zsh init/aliases)
    bat # file preview in fzf alias
    zoxide # directory jumping (zsh init)
    ruby
    nautilus # file manager (hyprland.lua)
    xdg-utils # xdg-open etc.
    hyprshot  # Screenshot tool
    hypridle # idle daemon (hypridle.conf)
    hyprlock # screen locker
    pamixer  # Audio control
    playerctl # Media control
    brightnessctl # Brightness control
    wl-clipboard # Wayland clipboard (pbcopy alias)
    imagemagick
    ffmpeg
    curl
    libnotify # notify-send
    qt6Packages.qt6ct # Qt theming
    glib # GTK/GNOME integration
    ani-cli
    chromium
    zathura
    lua-language-server
    tailwindcss-language-server
    typescript # Go-based TypeScript LSP (tsgo binary, used by neovim; formerly typescript-go)
    btop
    uwsm
    # NOTE: omarchy, better-control, yin-yang are AUR-only, unavailable in nixpkgs
  ];

  # Activation script to handle dotfiles and wallpaper
  system.activationScripts.dotfiles = pkgs.lib.stringAfter [ "users" ] ''
    # Copy dotfiles to home directory
    mkdir -p /home/nixos
    cp -r ${dotfiles} /home/nixos/.dotfiles

    # Stow dotfiles
    cd /home/nixos/.dotfiles
    ${pkgs.stow}/bin/stow -Sv hypr waybar nvim kitty zellij systemd zsh
    git reset --hard

    # Initialize zsh config from dotfiles
    cp /home/nixos/.config/zsh/.zshrc.template /home/nixos/.zshrc

    # Create directories
    cd /home/nixos
    mkdir -p Projects Codebases Personal Tools

    # Install neovim plugins
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

    # Copy wallpaper to home directory
    mkdir -p /home/nixos/wallpapers
    cp ${./city.jpg} /home/nixos/wallpapers/city.jpg

    # Copy curser theme to home directory
    mkdir -p /home/nixos/.icons
    cp ${cursors} /home/nixos/.icons/

    # Set up zsh completions for GitHub CLI
    mkdir -p /home/nixos/.zsh/completions
    ${pkgs.gh}/bin/gh completion -s zsh > /home/nixos/.zsh/completions/_gh

    # Hand-off home directory to the user
    chown -R nixos:users /home/nixos
  '';

  # Miscellaneous live ISO tweaks
  image.fileName = "nixos-hyprland.iso";
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Enable Wi-Fi
  networking.wireless.enable = false;
  networking.networkmanager.enable = true; # proivder nmcli, nmtui

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # provides bluetoothctl
}
