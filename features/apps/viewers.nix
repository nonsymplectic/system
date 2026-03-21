# Media viewer applications feature
# Home Manager only - document and media viewers
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.viewers;
in {
  options.features.viewers = {
    enable = lib.mkEnableOption "Media viewer applications";

    defaultPdfViewer = lib.mkOption {
      type = lib.types.enum ["zathura" "none"];
      default = "zathura";
      description = "Default PDF viewer for XDG MIME associations";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # Document viewer
        programs.zathura.enable = true;

        # Video player
        programs.mpv.enable = true;

        # Image viewers
        programs.imv.enable = true;

        home.packages = with pkgs; [
          swayimg # Wayland-native image viewer
        ];

        # Set PDF MIME association
        xdg.mimeApps.defaultApplications = lib.mkIf (cfg.defaultPdfViewer == "zathura") {
          "application/pdf" = "org.pwmt.zathura.desktop";
        };
      }
    ];
  };
}
