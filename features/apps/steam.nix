# Steam feature
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.steam;
in {
  options.features.steam = {
    enable = lib.mkEnableOption "Enable Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
