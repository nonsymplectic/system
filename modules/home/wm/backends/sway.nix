{ config, lib, pkgs }:

let
  cfg = config.my.wm;

  menuCmd =
    if cfg.launcher == "wofi" then "wofi --show drun"
    else if cfg.launcher == "fuzzel" then "fuzzel"
    else "bemenu-run";

  baseKeybindings = {
    "Mod4+Return"  = "exec ${cfg.terminal}";
    "Mod4+d"       = "exec ${menuCmd}";
    "Mod4+Shift+e" = "exec swaymsg exit";
    "Mod4+Shift+q" = "kill"
  };

  keybindings = baseKeybindings // cfg.keybindingOverrides;

in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      terminal = cfg.terminal;
      menu = menuCmd;
      keybindings = keybindings;
    };

    # Backend-native config append hook (WM-agnostic option name)
    extraConfig = cfg.extraConfig;
  };
}
