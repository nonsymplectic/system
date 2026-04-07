# Code formatter applications feature
# Home Manager only - language formatters
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.minecraft;
in {
  options.features.minecraft = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Minecraft";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = [
          pkgs.prismlauncher
          pkgs.jdk25_headless # needed for minecraft 26.1
        ];
      }
    ];
  };
}
