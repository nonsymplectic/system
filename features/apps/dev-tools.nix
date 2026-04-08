# Dev tools feature
# Home Manager only - lightweight developer tooling
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.dev-tools;
in {
  options.features.dev-tools = {
    enable = lib.mkEnableOption "developer tools";

    uv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable uv, the Python package/project manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = lib.optionals cfg.uv [
          pkgs.uv
        ];
      }
    ];
  };
}
