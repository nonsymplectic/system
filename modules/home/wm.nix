{ config, lib, pkgs, ... }:

let
  cfg = config.my.wm;
  ui  = config.my.ui;

  swayBackend = import ./wm/backends/sway.nix { inherit config lib pkgs ui cfg; };
in
{
  options.my.wm = {
    enable = lib.mkEnableOption "window manager";

    backend = lib.mkOption {
      type = lib.types.enum [ "sway" ];
      default = "sway";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "foot";
    };

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" "fuzzel" "bemenu" ];
      default = "wofi";
    };

    extraKeybindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };

    extraSwayConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.backend == "sway") swayBackend)

    {
      # launcher pkgs, terminal pkgs, generic WM tooling
      home.packages =
        (with pkgs; [ ]) ++
        (lib.optionals (cfg.terminal == "foot") [ pkgs.foot ]) ++
        (lib.optionals (cfg.launcher == "wofi") [ pkgs.wofi ]) ++
        (lib.optionals (cfg.launcher == "fuzzel") [ pkgs.fuzzel ]) ++
        (lib.optionals (cfg.launcher == "bemenu") [ pkgs.bemenu ]);

      # portals are still WM-adjacent and belong here
      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    }
  ]);
}
