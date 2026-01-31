{ config, lib, pkgs, ui }:

let
  cfg = config.my.wm;

  /* ============================================================
     Sway backend (Home Manager layer)
     ============================================================ */


  /* ============================================================
     Launcher command (backend interpretation)
     ============================================================ */

  menuCmd =
    if cfg.launcher == "wofi" then "wofi --show drun"
    else if cfg.launcher == "fuzzel" then "fuzzel"
    else "bemenu-run";


  /* ============================================================
     Client colors
     ------------------------------------------------------------
     Focus styling:
       - Keep borders neutral
       - Color the title text for the focused container
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
     Keybindings
     ------------------------------------------------------------
     Backend defaults + user overrides.
     ============================================================ */

  baseKeybindings = {
    # ----------------------------------------------------------
    # Launch / session
    # ----------------------------------------------------------
    "Mod4+Return" = "exec ${cfg.terminal}";
    "Mod4+d" = "exec ${menuCmd}";
    "Mod4+Shift+q" = "kill";
    "Mod4+Shift+r" = "reload";
    "Mod4+Shift+e" = "exec swaymsg exit";

    # ----------------------------------------------------------
    # Focus movement (vim + arrows)
    # ----------------------------------------------------------
    "Mod4+h" = "focus left";
    "Mod4+j" = "focus down";
    "Mod4+k" = "focus up";
    "Mod4+l" = "focus right";
    "Mod4+Left" = "focus left";
    "Mod4+Down" = "focus down";
    "Mod4+Up" = "focus up";
    "Mod4+Right" = "focus right";

    # Focus parent (escape nested containers)
    "Mod4+a" = "focus parent";

    # ----------------------------------------------------------
    # Container movement (vim + arrows)
    # ----------------------------------------------------------
    "Mod4+Shift+h" = "move left";
    "Mod4+Shift+j" = "move down";
    "Mod4+Shift+k" = "move up";
    "Mod4+Shift+l" = "move right";
    "Mod4+Shift+Left" = "move left";
    "Mod4+Shift+Down" = "move down";
    "Mod4+Shift+Up" = "move up";
    "Mod4+Shift+Right" = "move right";

    # ----------------------------------------------------------
    # Layout: tabbed / stacking / splits (Sway defaults)
    # ----------------------------------------------------------
    "Mod4+s" = "layout stacking";
    "Mod4+w" = "layout tabbed";
    "Mod4+e" = "layout toggle split";
    "Mod4+b" = "splith";
    "Mod4+v" = "splitv";

    # ----------------------------------------------------------
    # Fullscreen / floating
    # ----------------------------------------------------------
    "Mod4+f" = "fullscreen toggle";
    "Mod4+Shift+space" = "floating toggle";
    "Mod4+space" = "focus mode_toggle";

    # ----------------------------------------------------------
    # Workspaces (1-10) + move container to workspace
    # ----------------------------------------------------------
    "Mod4+1" = "workspace number 1";
    "Mod4+2" = "workspace number 2";
    "Mod4+3" = "workspace number 3";
    "Mod4+4" = "workspace number 4";
    "Mod4+5" = "workspace number 5";
    "Mod4+6" = "workspace number 6";
    "Mod4+7" = "workspace number 7";
    "Mod4+8" = "workspace number 8";
    "Mod4+9" = "workspace number 9";
    "Mod4+0" = "workspace number 10";

    "Mod4+Shift+1" = "move container to workspace number 1";
    "Mod4+Shift+2" = "move container to workspace number 2";
    "Mod4+Shift+3" = "move container to workspace number 3";
    "Mod4+Shift+4" = "move container to workspace number 4";
    "Mod4+Shift+5" = "move container to workspace number 5";
    "Mod4+Shift+6" = "move container to workspace number 6";
    "Mod4+Shift+7" = "move container to workspace number 7";
    "Mod4+Shift+8" = "move container to workspace number 8";
    "Mod4+Shift+9" = "move container to workspace number 9";
    "Mod4+Shift+0" = "move container to workspace number 10";

    # Workspace back-and-forth
    "Mod4+Tab" = "workspace back_and_forth";

    # ----------------------------------------------------------
    # Resize mode
    # ----------------------------------------------------------
    "Mod4+r" = "mode resize";
  };

  keybindings = baseKeybindings // cfg.keybindingOverrides;

in
{
  /* ============================================================
     Home Manager sway module
     ============================================================ */

  wayland.windowManager.sway = {
    enable = true;

    wrapperFeatures.gtk = true;

    extraOptions = cfg.backendFlags.sway or [ ];

    config = {
      terminal = cfg.terminal;
      menu = menuCmd;

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
