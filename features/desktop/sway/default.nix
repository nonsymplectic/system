# Sway window manager feature
# Includes both NixOS system configuration and Home Manager user configuration
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.sway;
  ui = config.my.ui;

  hex = c: lib.removePrefix "#" c;
  alpha = a: c: "${hex c}${a}";

  # Swaylock configuration derived from UI tokens
  swaylockSettings = import ./swaylockSettings.nix {inherit alpha ui;};

  # Waybar autostart if enabled
  barAutostart = lib.optionalString config.features.waybar.enable ''
    exec sh -lc '${pkgs.procps}/bin/pgrep -x waybar >/dev/null || exec waybar'
  '';

  disableFloating = ''
    for_window [floating] floating disable
  '';

  wallpaperPath = ../../../options/wallpapers/wall.png;
  wallpaperSetting = ''
    output * bg ${wallpaperPath} fill
  '';

  # Sway window colors derived from UI tokens
  clientColors = import ./clientColors.nix {inherit ui;};
  baseKeybindings = import ./baseKeybindings.nix {inherit config pkgs;};
in {
  options.features.sway = {
    enable = lib.mkEnableOption "Sway window manager";

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra CLI flags for sway (e.g., --unsupported-gpu)";
    };

    extraConfig = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra sway configuration";
    };

    keybindings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Additional keybindings to merge with defaults";
    };
  };

  config = lib.mkIf cfg.enable {
    # NixOS system-level configuration
    services.displayManager.sessionPackages = [pkgs.sway];
    security.pam.services.swaylock = {};

    # XDG portal for screen sharing, etc.
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.common.default = "*"; # Use first portal in lexicographical order
    };

    # Home Manager user-level configuration
    home-manager.sharedModules = [
      {
        # Mako notification daemon
        services.mako = {
          enable = true;

          settings = {
            background-color = ui.colors.background;
            text-color = ui.colors.foreground;
            border-color = ui.colors.muted;
            progress-color = "over ${ui.colors.focus}";
          };

          extraConfig = ''
            [urgency=high]
            border-color=${ui.colors.error}

            [urgency=normal]
            border-color=${ui.colors.focus}
          '';
        };

        # Swaylock for lockscreen
        programs.swaylock = {
          enable = true;
          package = pkgs.swaylock-effects;
          settings = swaylockSettings;
        };

        # Sway window manager
        wayland.windowManager.sway = {
          enable = true;
          systemd.enable = true;
          wrapperFeatures.gtk = true;

          extraOptions = cfg.extraFlags;

          config = lib.mkMerge [
            {
              defaultWorkspace = "workspace number 1";
              workspaceLayout = "tabbed";

              terminal = "foot";
              menu = "exec fuzzel";

              fonts = {
                names = [ui.font.family];
                size = builtins.toString ui.font.size;
              };

              colors = clientColors;

              keybindings = baseKeybindings // cfg.keybindings;
            }

            # Disable built-in swaybar when using waybar
            (lib.mkIf config.features.waybar.enable {bars = [];})
          ];

          extraConfig = disableFloating + barAutostart + wallpaperSetting + cfg.extraConfig;
        };
      }
    ];
  };
}
