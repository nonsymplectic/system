{ config, lib, pkgs, ... }:

let
  d = config.my.desktop;

  anyDmEnabled =
    (config.services.displayManager.ly.enable or false)
    || (config.services.displayManager.gdm.enable or false)
    || (config.services.displayManager.sddm.enable or false)
    || (config.services.displayManager.lightdm.enable or false)
    || (config.services.xserver.displayManager.startx.enable or false)
    || (config.services.greetd.enable or false);

  # Policy WM identifier → package providing a wayland session entry.
  wmPkgs = {
    sway = pkgs.sway;
    # hyprland = pkgs.hyprland;
    # river = pkgs.river;
    # niri = pkgs.niri;
  };

  wmSessionPkg = wmPkgs.${d.wm} or null;

in
{
  config = lib.mkIf (d.enable && anyDmEnabled && wmSessionPkg != null) {
    services.displayManager.sessionPackages =
      lib.mkAfter [ wmSessionPkg ];

    # Optional: expose the WM binary system-wide as well.
    # environment.systemPackages = lib.mkAfter [ wmSessionPkg ];
  };
}
