{ ... }:

{
  /* ============================================================
     Host configuration (NixOS layer)
     ------------------------------------------------------------
     Purpose:
       - Host-specific hardware + boot policy
       - Minimal host identity (hostname, timezone)
       - Import shared role profiles (e.g. workstation)
     ============================================================ */


  /* ============================================================
     Imports
     ------------------------------------------------------------
     Host-local modules first (hardware/users), then shared profiles.
     ============================================================ */

  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./users.nix
    ./swap.nix

    # Shared role profile (host-agnostic)
    ../../profiles/workstation.nix
  ];


  /* ============================================================
     Host identity
     ============================================================ */

  networking.hostName = "nixos";
  time.timeZone = "Europe/Zurich";


  /* ============================================================
     Boot policy (host-specific)
     ============================================================ */

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
