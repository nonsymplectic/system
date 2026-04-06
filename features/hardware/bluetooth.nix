# Bluetooth feature
# System-level only - enables bluetooth hardware
{
  config,
  lib,
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
  };
}
