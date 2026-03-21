# Wlsunset - automatic color temperature adjustment
# Home Manager only - red light filter service
{
  config,
  lib,
  ...
}: let
  cfg = config.features.wlsunset;
in {
  options.features.wlsunset = {
    enable = lib.mkEnableOption "Wlsunset color temperature adjustment";

    temperature = {
      day = lib.mkOption {
        type = lib.types.int;
        default = 6500;
        description = "Daytime color temperature in Kelvin";
      };

      night = lib.mkOption {
        type = lib.types.int;
        default = 2750;
        description = "Nighttime color temperature in Kelvin";
      };
    };

    location = {
      latitude = lib.mkOption {
        type = lib.types.str;
        default = "47.3769";
        description = "Latitude for sunrise/sunset calculation";
      };

      longitude = lib.mkOption {
        type = lib.types.str;
        default = "8.5417";
        description = "Longitude for sunrise/sunset calculation";
      };
    };

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default =
        if config.features.sway.enable or false
        then "sway-session.target"
        else "graphical-session.target";
      description = ''
        Systemd target to bind the service to.
        Auto-detects based on enabled WM features.
        Common values: "graphical-session.target", "sway-session.target", "hyprland-session.target"
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        services.wlsunset = {
          enable = true;

          temperature = {
            day = cfg.temperature.day;
            night = cfg.temperature.night;
          };

          latitude = cfg.location.latitude;
          longitude = cfg.location.longitude;

          systemdTarget = cfg.systemdTarget;
        };
      }
    ];
  };
}
