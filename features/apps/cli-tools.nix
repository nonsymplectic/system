# CLI tools feature
# Home Manager only - command-line utilities and system monitors
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.cli-tools;
in {
  options.features.cli-tools = {
    enable = lib.mkEnableOption "CLI tools and utilities";

    monitoring = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable system monitoring tools (btop, htop, ps_mem)";
    };

    utilities = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable general utilities (neofetch, claude-code)";
    };

    audio = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable audio utilities (wiremix)";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.btop.enable = lib.mkIf cfg.monitoring true;

        home.packages =
          (lib.optionals cfg.monitoring [
            pkgs.htop
            pkgs.ps_mem
          ])
          ++ (lib.optionals cfg.utilities [
            pkgs.neofetch
            pkgs.claude-code
          ])
          ++ (lib.optionals cfg.audio [
            pkgs.wiremix
          ]);
      }
    ];
  };
}
