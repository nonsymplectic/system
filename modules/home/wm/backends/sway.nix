{ config, lib, pkgs, ui }:

let
  cfg = config.my.wm;

  /* ============================================================
     Sway backend (Home Manager layer)
     ============================================================ */

  menuCmd =
    if cfg.launcher == "wofi" then "wofi --show drun"
    else if cfg.launcher == "fuzzel" then "fuzzel"
    else "bemenu-run";


  /* ============================================================
     Client colors
     ------------------------------------------------------------
     Focus styling:
       - No visible borders
       - Focus indicated via title text color
     ============================================================ */

  clientColors = {
    focused = {
      border = ui.colors.border;
      indicator = ui.colors.border;
      childBorder = ui.colors.border;
      background = ui.colors.background;
      text = ui.colors.focus;
    };

    focusedInactive = {
      border = ui.colors.border;
      childBorder = ui.colors.border;
      indicator = ui.colors.muted;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };

    unfocused = {
      border = ui.colors.border;
      childBorder = ui.colors.border;
      indicator = ui.colors.muted;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };

    urgent = {
      border = ui.colors.error;
      indicator = ui.colors.error;
      childBorder = ui.colors.error;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };

    placeholder = {
      border = ui.colors.muted;
      indicator = ui.colors.muted;
      childBorder = ui.colors.muted;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };
  };


  /* ============================================================
     Keybindings (Sway defaults)
     ============================================================ */

  baseKeybindings = {
    "Mod4+Return" = "exec ${cfg.terminal}";
    "Mod4+d" = "exec ${menuCmd}";
    "Mod4+Shift+q" = "kill";
    "Mod4+Shift+r" = "reload";
    "Mod4+Shift+e" = "exec swaymsg exit";

    "Mod4+h" = "focus left";
    "Mod4+j" = "focus down";
    "Mod4+k" = "focus up";
    "Mod4+l" = "focus right";

    "Mod4+Shift+h" = "move left";
    "Mod4+Shift+j" = "move down";
    "Mod4+Shift+k" = "move up";
    "Mod4+Shift+l" = "move right";

    "Mod4+s" = "layout stacking";
    "Mod4+w" = "layout tabbed";
    "Mod4+e" = "layout toggle split";
    "Mod4+b" = "splith";
    "Mod4+v" = "splitv";

    "Mod4+f" = "fullscreen toggle";
    "Mod4+space" = "focus mode_toggle";
    "Mod4+Shift+space" = "floating toggle";

    "Mod4+r" = "mode resize";
  };

  keybindings = baseKeybindings // cfg.keybindingOverrides;

in
{
  wayland.windowManager.sway = {
    enable = true;

    wrapperFeatures.gtk = true;

    extraOptions = cfg.backendFlags.sway or [ ];

    config = {
      terminal = cfg.terminal;
      menu = menuCmd;

      /* --------------------------------------------------------
         Border policy
         --------------------------------------------------------
         No visible borders; focus indicated via title text.
         -------------------------------------------------------- */
      window = {
        border = 0;
      };

      fonts = {
        names = [ ui.font.family ];
        size = builtins.toString ui.font.size;
      };

      colors = clientColors;
      keybindings = keybindings;
    };

    extraConfig = cfg.extraConfig;
  };
}
