# Communication applications feature
# Home Manager only - messaging and email clients
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.features.communication;
in {
  options.features.communication = {
    enable = lib.mkEnableOption "Communication applications";

    dino = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Dino XMPP client";
    };

    protonmail = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Proton Mail desktop client";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.dino [pkgs.dino])
          ++ (lib.optionals cfg.protonmail [pkgsUnstable.protonmail-desktop]);
      }
    ];
  };
}
