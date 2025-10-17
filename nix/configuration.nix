{ config, pkgs, ... }:

let
  dotfiles = pkgs.fetchgit {
    url = "https://github.com/colorfulfool/dotfiles.git";
    hash = "sha256-URWCi3SNgWZavzN6K1WcXhedlPZkHmfhv7BnXwDEJF8=";
    leaveDotGit = true;
  };
  cursor-theme = pkgs.fetchgit {
    url = "https://github.com/ful1e5/BreezeX_Cursor.git";
    hash = "sha256-URWCi3SNgWZavzN6K1WcXhedlPZkHmfhv7BnXwDEJF8=";
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

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Enable zsh shell with completions
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.interactiveShellInit = ''
    # Add custom completions directory
    fpath=(~/.zsh/completions $fpath)
    autoload -U compinit && compinit
  '';

  # Install requested packages
  environment.systemPackages = with pkgs; [
    waybar
    wofi
    kitty
    zellij
    nerd-fonts.jetbrains-mono
    swaybg  # For setting wallpaper
    stow
    git
    gh      # GitHub CLI
    ruby
    kdePackages.dolphin     # File manager
    hyprshot    # Screenshot tool
    pamixer     # Audio control
    playerctl   # Media control
    brightnessctl # Brightness control
    ani-cli
    chromium
    lua-language-server
    btop
    uwsm
    blueberry
    impala
  ];

  # Activation script to handle dotfiles and wallpaper
  system.activationScripts.dotfiles = pkgs.lib.stringAfter [ "users" ] ''
    # Copy dotfiles to home directory
    mkdir -p /home/nixos
    cp -r ${dotfiles} /home/nixos/dotfiles

    # Stow dotfiles
    cd /home/nixos/dotfiles
    ${pkgs.stow}/bin/stow -Sv hypr waybar nvim kitty zellij systemd zed
    git reset --hard

    # Install neovim plugins
    nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

    # Copy wallpaper to home directory
    mkdir -p /home/nixos/wallpapers
    cp ${./city.jpg} /home/nixos/wallpapers/city.jpg

    # Copy curser theme to home directory
    mkdir -p /home/nixos/.icons
    cp ${cursor-theme} /home/nixos/.icons/

    # Set wallpaper
    ${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill &

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
    extraGroups = [ "wheel" "video" "audio" ];
    password = "";  # Empty password for live session
  };
  security.sudo.wheelNeedsPassword = false;

  # Ensure networking for live environment
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
}
