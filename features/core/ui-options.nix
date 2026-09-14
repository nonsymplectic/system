{lib, ...}: let
  inherit
    (lib)
    mkOption
    types
    ;

  # Terminal palette is the 16 ANSI colors in canonical order:
  # 0-7   = normal  (black, red, green, yellow, blue, magenta, cyan, white)
  # 8-15  = bright  (black, red, green, yellow, blue, magenta, cyan, white)
  ansi16 = types.addCheck (types.listOf types.str) (xs: builtins.length xs == 16);

  # Named view of ANSI 16-color palette
  ansi = {
    # Mocha
    black = "#1e1e2e";
    red = "#f38ba8";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    blue = "#89b4fa";
    magenta = "#f5c2e7";
    cyan = "#94e2d5";
    white = "#bac2de";

    brightBlack = "#585b70";
    brightRed = "#f38ba8";
    brightGreen = "#a6e3a1";
    brightYellow = "#f9e2af";
    brightBlue = "#89b4fa";
    brightMagenta = "#f5c2e7";
    brightCyan = "#94e2d5";
    brightWhite = "#a6adc8";

    # Latte

    # black = "#eff1f5";
    # red = "#d20f39";
    # green = "#40a02b";
    # yellow = "#df8e1d";
    # blue = "#1e66f5";
    # magenta = "#ea76cb";
    # cyan = "#179299";
    # white = "#4c4f69";

    # brightBlack = "#eff1f5";
    # brightRed = "#d20f39";
    # brightGreen = "#40a02b";
    # brightYellow = "#df8e1d";
    # brightBlue = "#1e66f5";
    # brightMagenta = "#ea76cb";
    # brightCyan = "#179299";
    # brightWhite = "#4c4f69";
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
in {
  /*
  ============================================================
  UI tokens
  ------------------------------------------------------------
  Small host-defined token set for UI configuration:
  - Scale factor
  - Typography (UI + monospace roles)
  - Semantic colors

  Defaults derived from Catpuccin
  Hosts may override any token per-host.
  ============================================================
  */

  /*
  ============================================================
  Options: my.ui (canonical schema)
  ============================================================
  */

  options.my.ui = {
    /*
    ============================================================
    Scale
    ------------------------------------------------------------
    Abstract scaling factor for downstream consumers.
    ============================================================
    */

    scale = mkOption {
      type = types.number;
      default = 1.0;
      description = ''
        Abstract UI scale factor for downstream consumers.
      '';
    };

    /*
    ============================================================
    Fonts
    ------------------------------------------------------------
    Two font roles: font + monoFont.
    Each role provides family and size.
    ============================================================
    */

    font = {
      family = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Primary UI font family.";
      };

      size = mkOption {
        type = types.int;
        default = 18;
        description = "Primary UI font size (pt).";
      };

      sizePx = mkOption {
        type = types.int;
        default = 25;
        description = "UI font size in px (for CSS-based components).";
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
        default = 18;
        description = "Monospace UI font size (pt).";
      };

      sizePx = mkOption {
        type = types.int;
        default = 25;
        description = "UI font size in px (for CSS-based components).";
      };
    };

    /*
    ============================================================
    Semantic colors (hex strings)
    ------------------------------------------------------------
    Colors are expressed as hex strings, e.g. "#rrggbb".
    ============================================================
    */

    colors = {
      # Reference ANSI slots (by name) for UI background/foreground.
      # This keeps terminal + UI aligned and avoids duplicate sources of truth.
      background = mkOption {
        type = types.str;
        default = ansi.black;
        description = "Background color (hex).";
      };
      foreground = mkOption {
        type = types.str;
        default = ansi.white;
        description = "Foreground/text color (hex).";
      };

      # Semantic roles (still ANSI-derived).
      primary = mkOption {
        type = types.str;
        default = ansi.green;
        description = "Primary/accent color (hex).";
      };
      secondary = mkOption {
        type = types.str;
        default = ansi.yellow;
        description = "Secondary accent color (hex).";
      };
      muted = mkOption {
        type = types.str;
        default = ansi.brightBlack;
        description = "Muted/disabled color (hex).";
      };
      border = mkOption {
        type = types.str;
        default = ansi.brightBlack;
        description = "Border/outline color (hex).";
      };
      focus = mkOption {
        type = types.str;
        default = ansi.green;
        description = "Focus/active indicator color (hex).";
      };
      error = mkOption {
        type = types.str;
        default = ansi.red;
        description = "Error color (hex).";
      };
      warning = mkOption {
        type = types.str;
        default = ansi.yellow;
        description = "Warning color (hex).";
      };
      success = mkOption {
        type = types.str;
        default = ansi.green;
        description = "Success color (hex).";
      };
    };
  };
}
