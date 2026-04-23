# Productivity applications feature
# Home Manager only - study and research tools
{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}: let
  cfg = config.features.productivity;
in {
  options.features.productivity = {
    enable = lib.mkEnableOption "Productivity applications";

    anki = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Anki flashcard app";
    };

    calibre = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Calibre ebook manager";
    };

    zotero = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Zotero reference manager";
    };
    hugo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable hugo static site generator";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.anki.enable = lib.mkIf cfg.anki true;

        home.packages =
          (lib.optionals cfg.calibre [pkgs.calibre])
          ++ (lib.optionals cfg.zotero [pkgsUnstable.zotero])
          ++ (lib.optionals cfg.hugo [pkgs.hugo]);
      }
    ];
  };
}
