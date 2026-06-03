{...}: {
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

  # Gaming
  features.steam.enable = true;

  # Enable hardware features
  features.nvidia.enable = true;
  features.bluetooth.enable = true;
  features.virtualization.enable = true;

  # Sway needs this flag because of nvidia drivers
  features.sway.extraFlags = [
    "--unsupported-gpu"
  ];

  # rearrange monitors
  features.sway.extraConfig = ''
    workspace 1 output HDMI-A-1
    output HDMI-A-1 mode 1920x1080@60Hz pos 0 0
    output DP-1 mode 1920x1080@60Hz pos 1920 0
  '';

  # BorgBackup configuration
  features.borgbackup = {
    enable = true;
    jobName = "backup";

    # directories = [
    # "Documents"
    # ];

    schedule = "daily";

    b2 = {
      bucket = "nixos-borgbackup";
      syncSchedule = "*:0/30"; # Sync every 30 minutes
    };

    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
      yearly = 2;
    };
  };

  # KeePassXC with automatic S3 sync
  features.keepassxc-sync = {
    enable = true;
    databasePath = "/home/michal/KeepassXC/db.kdbx";
    remotePath = "b2-backup:nixos-borgbackup/keepassxc/db.kdbx";
    rcloneRemote = "b2-backup";
  };
}
