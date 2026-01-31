{ config, lib, pkgs }:

let
  cfg = config.my.wm;

  /* ============================================================
     Sway backend (Home Manager layer)
     ------------------------------------------------------------
     Purpose:
       - Provide backend-specific defaults for sway
       - Interpret my.wm.* abstract options (terminal, launcher)
       - Merge user overrides (keybindingOverrides, extraConfig)
     ============================================================ */


  /* ============================================================
     Launcher command (backend interpretation)
     ============================================================ */

  menuCmd =
    if cfg.launcher == "wofi" then "wofi --show drun"
    else if cfg.launcher == "fuzzel" then "fuzzel"
    else "bemenu-run";


  /* ============================================================
     Keybindings
     ------------------------------------------------------------
     Backend defaults + user overrides.
     ============================================================ */

     baseKeybindings = {
       # ----------------------------------------------------------
       # Launch / session
       # ----------------------------------------------------------
       "Mod4+Return"  = "exec ${cfg.terminal}";
       "Mod4+d"       = "exec ${menuCmd}";
       "Mod4+Shift+q" = "kill";
       "Mod4+Shift+r" = "reload";
       "Mod4+Shift+e" = "exec swaymsg exit";

       # ----------------------------------------------------------
       # Focus movement (vim + arrows)
       # ----------------------------------------------------------
       "Mod4+h"    = "focus left";
       "Mod4+j"    = "focus down";
       "Mod4+k"    = "focus up";
       "Mod4+l"    = "focus right";
       "Mod4+Left"  = "focus left";
       "Mod4+Down"  = "focus down";
       "Mod4+Up"    = "focus up";
       "Mod4+Right" = "focus right";

       # Focus parent (escape nested containers)
       "Mod4+a" = "focus parent";

       # ----------------------------------------------------------
       # Container movement (vim + arrows)
       # ----------------------------------------------------------
       "Mod4+Shift+h"    = "move left";
       "Mod4+Shift+j"    = "move down";
       "Mod4+Shift+k"    = "move up";
       "Mod4+Shift+l"    = "move right";
       "Mod4+Shift+Left"  = "move left";
       "Mod4+Shift+Down"  = "move down";
       "Mod4+Shift+Up"    = "move up";
       "Mod4+Shift+Right" = "move right";

       # ----------------------------------------------------------
       # Layout: tabbed / stacking / splits
       # ----------------------------------------------------------
       "Mod4+w" = "layout tabbed";
       "Mod4+e" = "layout stacking";
       "Mod4+b" = "split h";
       "Mod4+v" = "split v";

       # ----------------------------------------------------------
       # Fullscreen / floating
       # ----------------------------------------------------------
       "Mod4+f" = "fullscreen toggle";
       "Mod4+Shift+space" = "floating toggle";
       "Mod4+space"       = "focus mode_toggle";

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

    # GTK wrapper ensures expected GUI app environment under sway
    wrapperFeatures.gtk = true;

    config = {
      terminal = cfg.terminal;
      menu = menuCmd;

      keybindings = keybindings;
    };

    # Backend-native config append hook (from WM-agnostic interface)
    extraConfig = cfg.extraConfig;
  };
}
