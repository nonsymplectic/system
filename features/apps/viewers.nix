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

    spotify = lib.mkOption {
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

    defaultEpubViewer = lib.mkOption {
      type = lib.types.enum [
        "epr"
        "none"
      ];
      default = "epr";
      description = "Default Epub viewer for XDG MIME associations";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # non HM
        home.packages = with pkgs; [vlc epr];

        # Document viewer
        programs.zathura.enable = true;

        # epr epub reader needs its own .desktop entry
        xdg.desktopEntries.epr = {
          name = "EPR";
          genericName = "EPUB Reader";
          comment = "Read EPUB books in the terminal with EPR";
          exec = "${pkgs.foot}/bin/foot -T epr ${pkgs.epr}/bin/epr %f";
          terminal = false; # Foot will handle the terminal
          mimeType = ["application/epub+zip"];
          categories = ["Office" "Viewer"];
        };

        # Video player
        programs.mpv.enable = true;

        # Image viewers
        programs.imv.enable = true;

        # Spotify
        programs.spotify-player = {
          enable = cfg.spotify;
          settings = {
            notify_timeout_in_secs = 5;
            enable_audio_visualization = true;
            device = {
              name = config.networking.hostName;
              type = "computer";
              volume = 100;
            };
          };
        };

        # Set MIME association
        xdg.mimeApps.defaultApplications = lib.mkMerge [
          (lib.mkIf (cfg.defaultPdfViewer == "zathura") {
            "application/pdf" = "org.pwmt.zathura.desktop";
          })

          (lib.mkIf (cfg.defaultEpubViewer == "epr") {
            "application/epub+zip" = "epr.desktop";
          })
        ];
      }
    ];
  };
}
