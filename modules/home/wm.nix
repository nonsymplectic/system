{ pkgs, config, ... }:
{
  # Make user-installed .desktop files discoverable by drun launchers (wofi, etc.)
  home.sessionVariables.XDG_DATA_DIRS =
    "${config.home.profileDirectory}/share"
    + ":/etc/profiles/per-user/${config.home.username}/share"
    + ":/run/current-system/sw/share";

  wayland.windowManager.sway = {
    enable = true;
    extraOptions = [ "--unsupported-gpu" ];
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

