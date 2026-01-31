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
  ];

  # --- Define home-manager shared modules
  home-manager.sharedModules = [
    ../modules/home/wm.nix
  ];
}
