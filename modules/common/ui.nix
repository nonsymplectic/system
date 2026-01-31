{ lib, ... }:

let
  inherit (lib)
    mkOption
    types
    ;

  # Terminal palette is the 16 ANSI colors in canonical order:
  # 0-7   = normal  (black, red, green, yellow, blue, magenta, cyan, white)
  # 8-15  = bright  (black, red, green, yellow, blue, magenta, cyan, white)
  ansi16 =
    types.addCheck (types.listOf types.str) (xs: builtins.length xs == 16);

in
{
  /* ============================================================
     UI tokens
     ------------------------------------------------------------
     Small host-defined token set for UI configuration:
     - Scale factor
     - Typography (UI + monospace roles)
     - Semantic colors
     - Terminal palette (ANSI 16)

     Defaults derived from Adwaita Dark.
     Hosts may override any token per-host.
     ============================================================ */


  /* ============================================================
     Options: my.ui (canonical schema)
     ============================================================ */

  options.my.ui = {

    /* ============================================================
       Scale
       ------------------------------------------------------------
       Abstract scaling factor for downstream consumers.
       ============================================================ */

    scale = mkOption {
      type = types.number;
      default = 1.0;
      description = ''
        Abstract UI scale factor for downstream consumers.
      '';
    };


    /* ============================================================
       Fonts
       ------------------------------------------------------------
       Two font roles: font + monoFont.
       Each role provides family and size.
       ============================================================ */

    font = {
      family = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Primary UI font family.";
      };

      size = mkOption {
        type = types.int;
        default = 16;
        description = "Primary UI font size (pt).";
      };
    };

    monoFont = {
      family = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Monospace UI font family.";
      };

      size = mkOption {
        type = types.int;
        default = 16;
        description = "Monospace UI font size (pt).";
      };
    };


    /* ============================================================
       Semantic colors (hex strings)
       ------------------------------------------------------------
       Colors are expressed as hex strings, e.g. "#rrggbb".
       Defaults derived from Adwaita Dark.
       ============================================================ */

    colors = {
      background = mkOption { type = types.str; default = "#1d1d20"; description = "Background color (hex)."; };
      foreground = mkOption { type = types.str; default = "#ffffff"; description = "Foreground/text color (hex)."; };
      primary = mkOption { type = types.str; default = "#1e78e4"; description = "Primary/accent color (hex)."; };
      secondary = mkOption { type = types.str; default = "#9841bb"; description = "Secondary accent color (hex)."; };
      muted = mkOption { type = types.str; default = "#5e5c64"; description = "Muted/disabled color (hex)."; };
      border = mkOption { type = types.str; default = "#241f31"; description = "Border/outline color (hex)."; };
      focus = mkOption { type = types.str; default = "#1e78e4"; description = "Focus/active indicator color (hex)."; };
      error = mkOption { type = types.str; default = "#c01c28"; description = "Error color (hex)."; };
      warning = mkOption { type = types.str; default = "#f5c211"; description = "Warning color (hex)."; };
      success = mkOption { type = types.str; default = "#2ec27e"; description = "Success color (hex)."; };
    };


    /* ============================================================
       Terminal colors
       ------------------------------------------------------------
       Terminal colors are expressed as hex strings.
       palette is the ANSI 16-color table in canonical order:
       - indices 0..7   normal  black..white
       - indices 8..15  bright  black..white
       ============================================================ */

    terminal = {
      background = mkOption { type = types.str; default = "#1d1d20"; description = "Terminal background (hex)."; };
      foreground = mkOption { type = types.str; default = "#ffffff"; description = "Terminal foreground (hex)."; };
      cursor = mkOption { type = types.str; default = "#ffffff"; description = "Terminal cursor color (hex)."; };

      palette = mkOption {
        type = ansi16;
        default = [
          "#241f31" # 0  black
          "#c01c28" # 1  red
          "#2ec27e" # 2  green
          "#f5c211" # 3  yellow
          "#1e78e4" # 4  blue
          "#9841bb" # 5  magenta
          "#0ab9dc" # 6  cyan
          "#c0bfbc" # 7  white

          "#5e5c64" # 8  bright black
          "#ed333b" # 9  bright red
          "#57e389" # 10 bright green
          "#f8e45c" # 11 bright yellow
          "#51a1ff" # 12 bright blue
          "#c061cb" # 13 bright magenta
          "#4fd2fd" # 14 bright cyan
          "#f6f5f4" # 15 bright white
        ];
        description = ''
          Terminal ANSI palette (16 colors), in canonical order.
        '';
      };
    };
  };


  config = { };
}
