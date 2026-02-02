{ lib, ... }:

{
  /* ============================================================
     Desktop plugin system (Home Manager layer)
     ------------------------------------------------------------
     Declarations only:
       - Defines the complete my.desktop.* interface:
           * types
           * defaults
           * descriptions
       - No wiring, no imports, no packages, no config side effects.
     ============================================================ */

  options.my.desktop = {
    /* ============================================================
       Top-level enable
       ============================================================ */

    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "desktop configuration";
    };


    /* ============================================================
       Window manager
       ============================================================ */

    wm = lib.mkOption {
      type = lib.types.enum [ "sway" ];
      default = "sway";
      description = "Window manager.";
    };


    /* ============================================================
       Terminal
       ============================================================ */

    terminal = lib.mkOption {
      type = lib.types.enum [ "foot" ];
      default = "foot";
      description = "Terminal implementation.";
    };


    /* ============================================================
       Launcher
       ============================================================ */

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" ];
      default = "wofi";
      description = "App launcher.";
    };


    /* ============================================================
       Bar
       ============================================================ */

    bar = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "bar";
      };

      backend = lib.mkOption {
        type = lib.types.enum [ "waybar" ];
        default = "waybar";
        description = "Bar implementation.";
      };

      position = lib.mkOption {
        type = lib.types.enum [ "top" "bottom" ];
        default = "bottom";
        description = "Bar location.";
      };
    };


    /* ============================================================
       ExtraFlags
       ============================================================ */
    extraFlags = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      example = { sway = [ "--unsupported-gpu" ]; };
      description = ''
        Extra CLI flags passed to the selected WM backend.
        Keys are backend names, values are lists of flags.
      '';
    };
  };
}
