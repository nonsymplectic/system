{ config, lib, pkgs, ... }:

let
  enabled = config.my.wm.enable && config.my.wm.backend == "sway";
in
{
  config = lib.mkIf enabled {

    # Display-manager-related fix:

    services.displayManager.defaultSession = "sway";

    # If you had DM env fixes (common examples):
    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
    };

  };
}
