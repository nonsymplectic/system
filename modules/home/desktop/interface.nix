{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop;
in
{
  /* ============================================================
     Window manager module (Home Manager layer)
     ------------------------------------------------------------
     Purpose:
       - Provide shared wiring (portals, generic integration)
       - Import implementations (wm / bar / terminal / launcher/ ...)
         which are responsible for:
           * self-gating via mkIf
           * installing their own packages via home.packages
     ============================================================ */


  /* ============================================================
     Module imports
     ------------------------------------------------------------
     Implementations must self-gate via:
       - cfg.enable
       - cfg.wm / cfg.bar.* / cfg.terminal / cfg.launcher / ...
     ============================================================ */

  imports = [
    # Window managers
    ./wms/sway.nix

    # Bars
    ./bars/waybar.nix

    # Terminals
    ./terminals/foot.nix

    # Launchers
    ./launchers/wofi.nix
  ];

  config = lib.mkIf cfg.enable {
    # ----------------------------------------------------------
    # Wayland portals (required for many desktop integrations)
    # ----------------------------------------------------------
    warnings = [
      ''
        my.desktop enabled:
          wm=${cfg.wm}
          terminal=${cfg.terminal}
          launcher=${cfg.launcher} (cmd=${toString (config.my.desktop._resolved.launcherCmd or "<unset>")})
          bar=${if cfg.bar.enable then cfg.bar.backend else "disabled"} (cmd=${toString (config.my.desktop._resolved.barCmd or "<unset>")})
      ''
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}
