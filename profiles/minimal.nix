{ pkgs, ... }:
{
  # --- Booting ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Connectivity baseline ---
  networking.networkmanager.enable = true;

  # --- Minimal system packages (available to all users) ---
  environment.systemPackages = with pkgs; [
    nix-search
    vim
    wget
    git
    tree
    openssh
  ];
}
