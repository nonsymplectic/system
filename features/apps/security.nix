# Security applications feature
# Home Manager only - password managers and security tools
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.security;
in {
  options.features.security = {
    enable = lib.mkEnableOption "Security applications";

    keepassxc = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable KeePassXC password manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = lib.optionals cfg.keepassxc [pkgs.keepassxc];
      }
    ];
  };
}
