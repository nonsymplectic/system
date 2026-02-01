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

  /* ============================================================
     UI tokens (policy)
     ------------------------------------------------------------
     Host-level overrides for UI tokens.
     ============================================================ */

  # my.ui = {
  #   font = {
  #     # Primary UI font size
  #     size = 11;
  #   };
  #
  #   monoFont = {
  #     # Monospace font size (terminal, code-heavy UI)
  #     size = 11;
  #   };
  # };


  /* ============================================================
     Window manager backend flags (policy)
     ------------------------------------------------------------
     Extra CLI flags passed to the selected WM backend.
     Keys correspond to backend names.
     ============================================================ */

  # sway needs this flag because of nvidia drivers

  my.desktop.extraFlags.sway = [
    "--unsupported-gpu"
  ];

}
