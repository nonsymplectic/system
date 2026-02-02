{ config, lib, pkgs, ... }:

let
  enabled = config.my.desktop.enable && config.my.desktop.wm == "sway";
in
{
  config = lib.mkIf enabled {

    # Display-manager-related fix:

    services.displayManager.defaultSession = "sway";
  };
}
