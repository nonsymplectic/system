# Utility applications feature
# Home Manager only - miscellaneous utilities
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.features.utilities;
in {
  options.features.utilities = {
    enable = lib.mkEnableOption "Utility applications";

    bluetooth-ui = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable bluetui";
    };

    anydesk = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable AnyDesk remote desktop";
    };

    udisks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable udisks disk tools";
    };

    tribler = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable tribler p2p";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages =
          lib.optionals cfg.anydesk [pkgs.anydesk] ++ lib.optionals cfg.tribler [pkgsUnstable.tribler];
      }
    ];
    services.udisks2.enable = cfg.udisks;
  };
}
