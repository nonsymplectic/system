{ config, ... }:

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

    # Shared role profile
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

  # sway needs this flag because of nvidia drivers
  my.wm.backendFlags.sway = [
    "--unsupported-gpu"
  ];
}
