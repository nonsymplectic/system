{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.browsers;
in {
  options.features.browsers = {
    enable = lib.mkEnableOption "Web browsers";

    defaultBrowser = lib.mkOption {
      type = lib.types.enum [
        "chromium"
        "qutebrowser"
        "librewolf"
      ];
      default = "librewolf";
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
      else "${pkgs.librewolf}/bin/librewolf";

    home-manager.sharedModules = [
      {
        programs.chromium.enable = true;
        programs.qutebrowser.enable = true;
        programs.librewolf.enable = true;

        home.packages = lib.optionals cfg.enableTor [pkgs.tor-browser];

        xdg.mimeApps.defaultApplications = let
          browserDesktop =
            if cfg.defaultBrowser == "chromium"
            then "chromium-browser.desktop"
            else if cfg.defaultBrowser == "qutebrowser"
            then "org.qutebrowser.qutebrowser.desktop"
            else "librewolf.desktop";
        in {
          "text/html" = browserDesktop;
          "x-scheme-handler/http" = browserDesktop;
          "x-scheme-handler/https" = browserDesktop;
        };
      }
    ];
  };
}
