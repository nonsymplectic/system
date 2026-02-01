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

  # Named view of ANSI 16-color palette
  ansi = rec {
    black = "#241f31";
    red = "#c01c28";
    green = "#2ec27e";
    yellow = "#f5c211";
    blue = "#1e78e4";
    magenta = "#9841bb";
    cyan = "#0ab9dc";
    white = "#c0bfbc";

    brightBlack = "#5e5c64";
    brightRed = "#ed333b";
    brightGreen = "#57e389";
    brightYellow = "#f8e45c";
    brightBlue = "#51a1ff";
    brightMagenta = "#c061cb";
    brightCyan = "#4fd2fd";
    brightWhite = "#f6f5f4";
  };

  ansiPalette = [
    ansi.black # black
    ansi.red # red
    ansi.green # green
    ansi.yellow # yellow
    ansi.blue # blue
    ansi.magenta # magenta
    ansi.cyan # cyan
    ansi.white # white

    ansi.brightBlack # bright black
    ansi.brightRed # bright red
    ansi.brightGreen # bright green
    ansi.brightYellow # bright yellow
    ansi.brightBlue # bright blue
    ansi.brightMagenta # bright magenta
    ansi.brightCyan # bright cyan
    ansi.brightWhite # bright white
  ];

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
        default = 15;
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
        default = 15;
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
      # Reference ANSI slots (by name) for UI background/foreground.
      # This keeps terminal + UI aligned and avoids duplicate sources of truth.
      background = mkOption { type = types.str; default = ansi.black; description = "Background color (hex)."; };
      foreground = mkOption { type = types.str; default = ansi.brightWhite; description = "Foreground/text color (hex)."; };

      # Semantic roles (still ANSI-derived).
      primary = mkOption { type = types.str; default = ansi.green; description = "Primary/accent color (hex)."; };
      secondary = mkOption { type = types.str; default = ansi.yellow; description = "Secondary accent color (hex)."; };
      muted = mkOption { type = types.str; default = ansi.brightBlack; description = "Muted/disabled color (hex)."; };
      border = mkOption { type = types.str; default = ansi.brightBlack; description = "Border/outline color (hex)."; };
      focus = mkOption { type = types.str; default = ansi.blue; description = "Focus/active indicator color (hex)."; };
      error = mkOption { type = types.str; default = ansi.red; description = "Error color (hex)."; };
      warning = mkOption { type = types.str; default = ansi.yellow; description = "Warning color (hex)."; };
      success = mkOption { type = types.str; default = ansi.green; description = "Success color (hex)."; };
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
      # Reference ANSI slots (by name) for terminal background/foreground/cursor.
      background = mkOption { type = types.str; default = ansi.black; description = "Terminal background (hex)."; };
      foreground = mkOption { type = types.str; default = ansi.brightWhite; description = "Terminal foreground (hex)."; };
      cursor = mkOption { type = types.str; default = ansi.brightWhite; description = "Terminal cursor color (hex)."; };

      palette = mkOption {
        type = ansi16;
        default = ansiPalette;
        description = ''
          Terminal ANSI palette (16 colors), in canonical order.
        '';
      };
    };
  };


  config = { };
}
