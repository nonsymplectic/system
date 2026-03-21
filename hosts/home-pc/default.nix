{config, ...}: {
  /*
  ============================================================
  Host configuration (NixOS layer)
  ------------------------------------------------------------
  Purpose:
    - Host-specific hardware
    - Minimal host identity (hostname, timezone)
    - Import shared role profiles (e.g. workstation)
    - Host-specific overrides
  ============================================================
  */

  /*
  ============================================================
  Imports
  ------------------------------------------------------------
  Host-local modules first (hardware/users), then shared profiles.
  ============================================================
  */

  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./users.nix
    ./swap.nix

    # Shared role profile
    ../../profiles/workstation.nix
  ];

  /*
  ============================================================
  Host identity
  ============================================================
  */

  networking.hostName = "home-pc";
  time.timeZone = "Europe/Zurich";

  /*
  ============================================================
  UI tokens
  ------------------------------------------------------------
  Host-level overrides for UI tokens.
  ============================================================
  */

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

  /*
  ============================================================
  Feature configuration
  ------------------------------------------------------------
  Host-specific feature overrides.
  ============================================================
  */

  # Enable hardware features
  features.nvidia.enable = true;
  features.bluetooth.enable = true;

  # Sway needs this flag because of nvidia drivers
  features.sway.extraFlags = [
    "--unsupported-gpu"
  ];
}
