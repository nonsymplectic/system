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
       - Dispatch to a bar implementation (optional)
       - Dispatch to a backend implementation (currently: sway)
     ============================================================ */


  /* ============================================================
     Module options (WM-agnostic interface)
     ------------------------------------------------------------
     These options live in the Home Manager option tree.
     They must be set from within HM scope (e.g. via sharedModules).
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
        default = null;
        readOnly = true;
        description = "Backend-provided bar launch command.";
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
     - Generic WM-adjacent packages derived from abstract choices
     - Wayland portal wiring (backend-agnostic)
     - Bar dispatch (optional)
     - Backend dispatch
     ============================================================ */

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
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
    }

    # ------------------------------------------------------------
    # Bar dispatch (optional)
    # ------------------------------------------------------------
    (lib.mkIf cfg.bar.enable (lib.mkMerge [
      (lib.mkIf (cfg.bar.backend == "waybar")
        (import ./wm/bars/waybar.nix { inherit config lib pkgs ui; })
      )
    ]))

    # ------------------------------------------------------------
    # Backend dispatch
    # ------------------------------------------------------------
    (lib.mkIf (cfg.backend == "sway")
      (import ./wm/backends/sway.nix { inherit config lib pkgs ui; })
    )
  ]);
}
