# Desktop support packages feature
# Home Manager only - essential system utilities for desktop environment
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.desktop-support;
in {
  options.features.desktop-support = {
    enable = lib.mkEnableOption "Desktop support utilities";

    audio = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PulseAudio/PipeWire utilities";
    };

    gtk = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GTK dconf support";
    };

    clipboard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Wayland clipboard utilities";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.audio [pkgs.pulseaudioFull])
          ++ (lib.optionals cfg.gtk [pkgs.dconf])
          ++ (lib.optionals cfg.clipboard [pkgs.wl-clipboard]);
      }
    ];
  };
}
