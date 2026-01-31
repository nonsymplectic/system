{ pkgs, ... }:
{
  imports = [
    ../modules/nixos/core/primary-user.nix # Defines my.primaryUser
    ../modules/nixos/services/ly.nix # Display Manager is system level
    ../modules/nixos/core/agenix.nix # Agenix encryption
  ];

  # --- Connectivity baseline ---
  networking.networkmanager.enable = true;

  # --- Minimal system packages (available to all users) ---
  environment.systemPackages = with pkgs; [
    nix-search
    vim
    wget
    tree
    htop
    git
  ];

  # --- Define home-manager shared modules
  # Make HM-provided desktop files and portal descriptors visible system-wide
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/wayland-sessions"
    "/share/xsessions"
  ];

  # Add WMs to sessionPackages
  services.displayManager.sessionPackages = with pkgs; [
    sway
  ];

  # Imports for home-manager managed stuff
  home-manager.sharedModules = [
    ../modules/home/wm.nix
    ../modules/home/apps.nix
    ../modules/home/core/git.nix
  ];
}
