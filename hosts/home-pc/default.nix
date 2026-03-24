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

  # Enable hardware features
  features.nvidia.enable = true;
  features.bluetooth.enable = true;

  # Sway needs this flag because of nvidia drivers
  features.sway.extraFlags = [
    "--unsupported-gpu"
  ];

  # BorgBackup configuration
  features.borgbackup = {
    enable = true;
    jobName = "backup";

    directories = [
      "Documents"
    ];

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
