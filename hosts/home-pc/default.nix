{ config, ... }:

{
  /* ============================================================
     Host configuration (NixOS layer)
     ------------------------------------------------------------
     Purpose:
       - Host-specific hardware
       - Minimal host identity (hostname, timezone)
       - Import shared role profiles (e.g. workstation)
       - Host-specific overrides
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

    # Shared role profile
    ../../profiles/workstation.nix
  ];


  /* ============================================================
     Host identity
     ============================================================ */

  networking.hostName = "nixos";
  time.timeZone = "Europe/Zurich";

  /* ============================================================
     UI tokens
     ------------------------------------------------------------
     Host-level overrides for UI tokens.
     ============================================================ */

  # my.ui = {
  #   font = {
  #     # Primary UI font size
  #     size = 15;
  #     sizePx = 20;
  #   };
  #
  #   monoFont = {
  #     # Monospace font size
  #     size = 15;
  #     sizePx = 20;
  #   };
  # };


  /* ============================================================
     WM tokens
     ------------------------------------------------------------
     Host-level overrides for WM tokens.
     ============================================================ */

  # Sway needs this flag because of nvidia drivers

  my.desktop.extraFlags.sway = [
    "--unsupported-gpu"
  ];

}
