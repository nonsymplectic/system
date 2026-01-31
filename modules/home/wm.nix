{ pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    extraOptions = ["--unsupported-gpu"]
    wrapperFeatures.gtk = true;
    config = {
      terminal = "foot";
      menu = "wofi --show drun";
    };
  };

  home.packages = with pkgs; [
    foot
    wofi
    swaybg
    wl-clipboard
    grim
    slurp
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
}
