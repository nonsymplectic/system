# Bluetooth feature
# enables bluetooth hardware, relevant tui
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.bluetooth;
in {
  options.features.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth support";

    powerOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Power on bluetooth adapter on boot";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.powerOnBoot;
      settings = {
        General = {
          # Shows battery charge of connected devices
          Experimental = true;
        };
        Policy = {
          AutoEnable = false;
        };
      };
    };
    home-manager.sharedModules = [
      {
        home.packages = [pkgs.bluetui];
        # bluetui needs its own .desktop entry
        xdg.desktopEntries.bluetui = {
          name = "bluetui";
          genericName = "Bluetooth Settings";
          comment = "Set Bluetooth settings with bluetui TUI.";
          exec = "${pkgs.foot}/bin/foot -T bluetui ${pkgs.bluetui}/bin/bluetui";
          terminal = false; # Foot will handle the terminal
          mimeType = [];
          categories = ["System"];
        };
      }
    ];
  };
}
