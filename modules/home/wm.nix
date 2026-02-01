{ config, lib, pkgs, ... }:

let
  cfg = config.my.wm;
in
{
  /* ============================================================
     Window manager module (Home Manager layer)
     ------------------------------------------------------------
     Purpose:
       - Declare a WM-agnostic interface under my.wm.*
       - Provide shared wiring (portals, generic integration)
       - Import implementations (backend / bar / terminal / launcher)
         which are responsible for:
           * self-gating via mkIf
           * installing their own packages via home.packages
     ============================================================ */


  /* ============================================================
     Module imports
     ------------------------------------------------------------
     Implementations must self-gate via:
       - cfg.enable
       - cfg.backend / cfg.bar.* / cfg.terminal / cfg.launcher
     ============================================================ */

  imports = [
    # Backends
    ./wm/backends/sway.nix

    # Bars
    ./wm/bars/waybar.nix

    # Terminals
    ./wm/terminals/foot.nix

    # Launchers
    ./wm/launchers/wofi.nix
  ];


  /* ============================================================
     Module options (WM-agnostic interface)
     ------------------------------------------------------------
     This module declares "policy" (selection) only.
     Implementations install packages and emit concrete configs.
     ============================================================ */

  options.my.wm = {
    enable = lib.mkEnableOption "window manager configuration";

    backend = lib.mkOption {
      type = lib.types.enum [ "sway" ];
      default = "sway";
      description = "WM backend.";
    };

    terminal = lib.mkOption {
      type = lib.types.enum [ "foot" ];
      default = "foot";
      description = "Terminal implementation.";
    };

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" ];
      default = "wofi";
      description = "App launcher.";
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
        default = null;
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
     This module provides shared wiring only.

     Package installation is delegated to implementation modules:
       - ./wm/backends/*
       - ./wm/bars/*
       - ./wm/terminals/*
       - ./wm/launchers/*
     ============================================================ */

  config = lib.mkIf cfg.enable {
    # ----------------------------------------------------------
    # Wayland portals (required for many desktop integrations)
    # ----------------------------------------------------------
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}
