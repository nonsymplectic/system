{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
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
  # Laptops might want smaller fonts, different bar position, etc.
  # Example overrides:
  # my.ui.font.size = 14;
  # features.waybar.position = "top";

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
}
