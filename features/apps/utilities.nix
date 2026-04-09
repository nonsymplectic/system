# Utility applications feature
# Home Manager only - miscellaneous utilities
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

    bluetooth-ui = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Blueman Bluetooth manager + bluetui";
    };

    anydesk = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable AnyDesk remote desktop";
    };

    udisks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable udisks disk tools";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.bluetooth-ui [pkgs.blueman pkgs.bluetui]) ++ (lib.optionals cfg.anydesk [pkgs.anydesk]);
      }
    ];
    services.udisks2.enable = cfg.udisks;
  };
}
