# Code formatter applications feature
# Home Manager only - language formatters
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.formatters;
in {
  options.features.formatters = {
    enable = lib.mkEnableOption "Code formatters";

    nix = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Alejandra Nix formatter";
    };

    python = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Black Python formatter";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.nix [pkgs.alejandra])
          ++ (lib.optionals cfg.python [pkgs.black]);
      }
    ];
  };
}
