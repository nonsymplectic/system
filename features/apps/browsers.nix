{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.browsers;
  ui = config.my.ui;
in {
  options.features.browsers = {
    enable = lib.mkEnableOption "Web browsers";

    defaultBrowser = lib.mkOption {
      type = lib.types.enum [
        "chromium"
        "qutebrowser"
        "firefox"
      ];
      default = "chromium";
      description = "Default web browser";
    };

    enableTor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Tor Browser";
    };

    command = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Command used to launch the configured default browser";
    };
  };

  config = lib.mkIf cfg.enable {
    features.browsers.command =
      if cfg.defaultBrowser == "chromium"
      then "${pkgs.chromium}/bin/chromium"
      else if cfg.defaultBrowser == "qutebrowser"
      then "${pkgs.qutebrowser}/bin/qutebrowser"
      else "${pkgs.firefox}/bin/firefox";

    home-manager.sharedModules = [
      {
        # ---------- chromium ----------
        programs.chromium.enable = true;

        # ---------- qutebrowser ----------
        programs.qutebrowser = {
          enable = true;
          settings = {
            fonts.default_size = "${toString ui.font.size}pt";
            zoom.default = "175%";
          };
          quickmarks = {
            blog = "https://mikuta.online/";
            ft = "https://www.ft.com/";
            yt = "https://invidious.nerdvpn.de/";
            nixpkgs = "https://search.nixos.org/packages";
            help = "https://raw.githubusercontent.com/qutebrowser/qutebrowser/main/doc/img/cheatsheet-big.png";
            chat = "https://chatgpt.com/";
            meteo = "https://www.meteoschweiz.admin.ch/lokalprognose/zuerich/8044.html#forecast-tab=detail-view";
          };
        };

        # ---------- firefox ----------
        programs.firefox.enable = true;

        home.packages = (lib.optionals cfg.enableTor [pkgs.tor-browser]) ++ [pkgs.w3m];

        xdg.mimeApps.defaultApplications = let
          browserDesktop =
            if cfg.defaultBrowser == "chromium"
            then "chromium-browser.desktop"
            else if cfg.defaultBrowser == "qutebrowser"
            then "org.qutebrowser.qutebrowser.desktop"
            else "firefox.desktop";
        in {
          "text/html" = browserDesktop;
          "x-scheme-handler/http" = browserDesktop;
          "x-scheme-handler/https" = browserDesktop;
        };
      }
    ];
  };
}
