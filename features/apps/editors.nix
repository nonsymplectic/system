# Editor applications feature
# Home Manager only - neovim and zed-editor
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.features.editors;
in {
  options.features.editors = {
    enable = lib.mkEnableOption "Editor applications";

    neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Neovim";
      };
    };

    zed = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Zed editor";
      };

      extensions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["nix"];
        description = "Zed extensions to install";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [nixd nil];
        description = "Extra packages for Zed (LSP servers, etc.)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.neovim.enable = lib.mkIf cfg.neovim.enable true;

        programs.zed-editor = lib.mkIf cfg.zed.enable {
          enable = true;
          package = pkgsUnstable.zed-editor;
          extensions = cfg.zed.extensions;
          extraPackages = cfg.zed.extraPackages;
        };
      }
    ];
  };
}
