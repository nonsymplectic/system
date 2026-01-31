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
    git
    ungoogled-chromium
  ];

  # --- Define home-manager shared modules
  # Make HM-provided desktop files and portal descriptors visible system-wide
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  home-manager.sharedModules = [
    ../modules/home/wm.nix
  ];
}
