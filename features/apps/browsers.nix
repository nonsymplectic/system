# Browser applications feature
# Home Manager only - installs and configures browsers
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
      type = lib.types.enum ["chromium" "qutebrowser"];
      default = "chromium";
      description = "Default web browser";
    };

    enableTor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Tor Browser";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.chromium.enable = true;
        programs.qutebrowser.enable = true;

        home.packages = lib.optionals cfg.enableTor [pkgs.tor-browser];

        # Set default browser
        xdg.mimeApps.defaultApplications = {
          "text/html" =
            if cfg.defaultBrowser == "chromium"
            then "chromium-browser.desktop"
            else "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/http" =
            if cfg.defaultBrowser == "chromium"
            then "chromium-browser.desktop"
            else "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/https" =
            if cfg.defaultBrowser == "chromium"
            then "chromium-browser.desktop"
            else "org.qutebrowser.qutebrowser.desktop";
        };
      }
    ];
  };
}
