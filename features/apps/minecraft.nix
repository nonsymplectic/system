# Code formatter applications feature
# Home Manager only - language formatters
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.features.minecraft;
in {
  options.features.minecraft = {
    enable = lib.mkEnableOption "Enable Minecraft";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = [
          pkgsUnstable.prismlauncher
        ];
      }
    ];
  };
}
