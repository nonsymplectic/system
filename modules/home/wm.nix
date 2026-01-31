{ config, lib, pkgs, ... }:

let
  cfg = config.my.wm;
in
{
  options.my.wm = {
    enable = lib.mkEnableOption "window manager configuration";

    backend = lib.mkOption {
      type = lib.types.enum [ "sway" ];
      default = "sway";
      description = "WM backend to configure.";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "foot";
      description = "Terminal command.";
    };

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" "fuzzel" "bemenu" ];
      default = "wofi";
      description = "App launcher used for drun.";
    };

    keybindingOverrides = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Backend-native keybinding overrides.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Backend-native config appended to the generated config.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Only generic WM-adjacent things here (packages derived from abstract choices).
      home.packages =
        lib.optionals (cfg.terminal == "foot") [ pkgs.foot ] ++
        lib.optionals (cfg.launcher == "wofi") [ pkgs.wofi ] ++
        lib.optionals (cfg.launcher == "fuzzel") [ pkgs.fuzzel ] ++
        lib.optionals (cfg.launcher == "bemenu") [ pkgs.bemenu ];

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    }

    (lib.mkIf (cfg.backend == "sway")
      (import ./wm/backends/sway.nix { inherit config lib pkgs; })
    )
  ]);
}
