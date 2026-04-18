# Input methods feature
# Home Manager only - fcitx5 and other input method frameworks
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.input-methods;
  fcitx5Home = "${config.xdg.configHome}/fcitx5";
in {
  options.features.input-methods = {
    enable = lib.mkEnableOption "Input method framework";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({
        pkgs,
        lib,
        ...
      }: {
        i18n.inputMethod = {
          enable = true;
          type = "fcitx5";
          fcitx5.addons = [
            pkgs.fcitx5
            pkgs.fcitx5-gtk
            pkgs.qt6Packages.fcitx5-chinese-addons
          ];
        };
      })
    ];
  };
}
