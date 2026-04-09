{...}: {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./swap.nix

    # Shared role profile
    ../../profiles/workstation.nix
  ];

  # Host identity
  networking.hostName = "laptop";
  time.timeZone = "Europe/Zurich";

  # Console keymap
  console.keyMap = "de";

  # sway keymap
  features.sway.extraConfig = ''
    input type:keyboard {
      xkb_layout de
      xkb_options caps:swapescape
    }
  '';

  # Feature configuration
  my.ui.font.size = 23;
  my.ui.font.sizePx = 31;

  my.ui.monoFont.size = 23;
  my.ui.monoFont.sizePx = 31;
  # features.waybar.position = "top";

  # Sway additional keybinds
  features.sway.keybindings = {
    # Turn off Laptop Screen
    "Mod4+Shift+m" = "output eDP-1 toggle";
  };

  # Hardware features
  features.bluetooth.enable = true;
  features.laptop-powersaving.enable = true;
  features.minecraft.enable = true;

  # BorgBackup configuration (same settings as home-pc for shared repository)
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
