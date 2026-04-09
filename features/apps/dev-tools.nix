# Dev tools feature
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
      description = "Enable uv";
    };

    nix-ld = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nix-ld for running non-Nix dynamic binaries";
    };

    lazygit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable lazygit";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = lib.mkIf cfg.nix-ld true;

    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.uv [pkgs.uv])
          ++ (lib.optionals cfg.lazygit [pkgs.lazygit]);
      }
    ];
  };
}
