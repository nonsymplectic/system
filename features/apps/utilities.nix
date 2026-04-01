# Utility applications feature
# Home Manager only - miscellaneous GUI utilities
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.utilities;
in {
  options.features.utilities = {
    enable = lib.mkEnableOption "Utility applications";

    blueman = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Blueman Bluetooth manager";
    };

    anydesk = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable AnyDesk remote desktop";
    };

    udiskie = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable udisk/udiskie disk tools";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.blueman [pkgs.blueman]) ++ (lib.optionals cfg.anydesk [pkgs.anydesk]);

        services.udiskie.enable = cfg.udiskie;
      }
    ];
    services.udisks2.enable = cfg.udiskie;
  };
}
