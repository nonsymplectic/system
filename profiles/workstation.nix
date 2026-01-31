{ pkgs, ... }:
{
  # system wide imports
  imports = [
    ../modules/nixos/core/primary-user.nix # Defines my.primaryUser, useful for home directories etc
    ../modules/nixos/services/ly.nix # Display Manager is system level
    ../modules/nixos/core/agenix.nix # Agenix encryption
  ];

  # Imports for home-manager managed stuff
  home-manager.sharedModules = [
    ../modules/home/wm.nix # wm backend
    ../profiles/home/workstation.nix # wm policy

    ../modules/home/apps.nix # user-level applications

    ../modules/home/core/git.nix # git config
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


  # Home Manager (useUserPackages) requires these paths to expose portal and DE configs
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # Add WMs to sessionPackages
  services.displayManager.sessionPackages = with pkgs; [
    sway
  ];
}
