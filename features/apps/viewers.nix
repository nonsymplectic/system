# Media viewer applications feature
# Home Manager only - document and media viewers
{
  config,
  lib,
  ...
}: let
  cfg = config.features.viewers;
in {
  options.features.viewers = {
    enable = lib.mkEnableOption "Media viewer applications";

    enableSpotify = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Spotify-Player";
    };

    defaultPdfViewer = lib.mkOption {
      type = lib.types.enum [
        "zathura"
        "none"
      ];
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

        # Spotify
        programs.spotify-player = {
          enable = cfg.enableSpotify;
          settings.notify_timeout_in_secs = 5;
        };

        # home.packages = with pkgs; [
        #   swayimg # Wayland-native image viewer
        # ];

        # Set PDF MIME association
        xdg.mimeApps.defaultApplications = lib.mkIf (cfg.defaultPdfViewer == "zathura") {
          "application/pdf" = "org.pwmt.zathura.desktop";
        };
      }
    ];
  };
}
