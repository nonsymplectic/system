{ config, lib, pkgs, ui, ... }:

let
  cfg = config.my.wm;
in
{
  /* ============================================================
     Window manager module (Home Manager layer)
     ------------------------------------------------------------
     Purpose:
       - Declare a WM-agnostic interface under my.wm.*
       - Install WM-adjacent user packages (terminal, launcher)
       - Import backend + bar implementations (self-gated via mkIf)
     ============================================================ */


  /* ============================================================
     Module imports
     ------------------------------------------------------------
     Backends / bars must gate themselves via cfg.backend / cfg.bar.*
     ============================================================ */

  imports = [
    ./wm/backends/sway.nix
    ./wm/bars/waybar.nix
  ];


  /* ============================================================
     Module options (WM-agnostic interface)
     ============================================================ */

  options.my.wm = {
    enable = lib.mkEnableOption "window manager configuration";

    backend = lib.mkOption {
      type = lib.types.enum [ "sway" ];
      default = "sway";
      description = "WM backend to configure.";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "foot";
      description = "Terminal command.";
    };

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" "fuzzel" "bemenu" ];
      default = "wofi";
      description = "App launcher used for drun.";
    };

    /* ============================================================
       Bar
       ============================================================ */

    bar = {
      enable = lib.mkEnableOption "bar";

      backend = lib.mkOption {
        type = lib.types.enum [ "waybar" ];
        default = "waybar";
        description = "Bar implementation.";
      };

      position = lib.mkOption {
        type = lib.types.enum [ "top" "bottom" "left" "right" ];
        default = "top";
        description = "Bar location.";
      };

      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "waybar";
        description = "Bar launch command provided by the selected bar module.";
      };
    };

    keybindingOverrides = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Backend-native keybinding overrides.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Backend-native config appended to the generated config.";
    };

    backendFlags = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      example = { sway = [ "--unsupported-gpu" ]; };
      description = ''
        Extra CLI flags passed to the selected WM backend.
        Keys are backend names, values are lists of flags.
      '';
    };
  };


  /* ============================================================
     Configuration (enabled only)
     ------------------------------------------------------------
     Backend/bar implementations are imported unconditionally and
     must be self-gated; this module only provides common wiring.
     ============================================================ */

  config = lib.mkIf cfg.enable {
    # ----------------------------------------------------------
    # User packages: terminal + launcher (abstract selection)
    # ----------------------------------------------------------
    home.packages =
      lib.optionals (cfg.terminal == "foot") [ pkgs.foot ] ++
      lib.optionals (cfg.launcher == "wofi") [ pkgs.wofi ] ++
      lib.optionals (cfg.launcher == "fuzzel") [ pkgs.fuzzel ] ++
      lib.optionals (cfg.launcher == "bemenu") [ pkgs.bemenu ];

    # ----------------------------------------------------------
    # Wayland portals (required for many desktop integrations)
    # ----------------------------------------------------------
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}
