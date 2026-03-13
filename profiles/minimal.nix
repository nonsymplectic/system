{pkgs, ...}: {
  /*
  ============================================================
  NixOS module imports
  ============================================================
  */
  imports = [
    # Nix settings
    ../modules/nixos/core/nix.nix

    # Declares primaryUser plumbing
    ../modules/nixos/core/primary-user.nix
  ];

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

    # shorthand for rebuilding system config
    (writeShellScriptBin "system-rebuild" ''
      exec nixos-rebuild switch --flake ".#$(hostname)"
    '')
  ];
}
