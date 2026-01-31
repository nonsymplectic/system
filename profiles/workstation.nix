{ pkgs, ... }:
{
  imports = [
    ../modules/nixos/services/ly.nix # Display Manager
  ];

  # --- Connectivity baseline ---
  networking.networkmanager.enable = true;

  # --- Minimal system packages (available to all users) ---
  environment.systemPackages = with pkgs; [
    nix-search
    vim
    wget
    tree
    git
    ungoogled-chromium
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

  home-manager.sharedModules = [
    ../modules/home/wm.nix
  ];
}
