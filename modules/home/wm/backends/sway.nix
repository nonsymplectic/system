{ config, lib, pkgs, ui, cfg }:

let
  menu =
    if cfg.launcher == "wofi" then "wofi --show drun"
    else if cfg.launcher == "fuzzel" then "fuzzel"
    else "bemenu-run";

  baseKeybindings = {
    "Mod4+Return" = "exec ${cfg.terminal}";
    "Mod4+d"      = "exec ${menu}";
    "Mod4+Shift+e" = "exec swaymsg exit";
  };

  keybindings = baseKeybindings // cfg.extraKeybindings;

  font = "${ui.font.name} ${toString ui.font.size}";
in
{
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      terminal = cfg.terminal;
      menu = menu;
      fonts = { names = [ ui.font.name ]; size = ui.font.size; };

      keybindings = keybindings;

      # keep the rest “shared + invariant”
      # ...
    };

    extraConfig = cfg.extraSwayConfig;
    extraOptions = [ "--unsupported-gpu" ];
  };
}
