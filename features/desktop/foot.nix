# Foot terminal emulator feature
# Home Manager only - no system-level configuration needed
{
  config,
  lib,
  ...
}: let
  cfg = config.features.foot;
  ui = config.my.ui;
in {
  options.features.foot = {
    enable = lib.mkEnableOption "Foot terminal emulator";

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra settings to pass to programs.foot.settings";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration
    home-manager.sharedModules = [
      {
        programs.foot = {
          enable = true;

          settings =
            {
              main = {
                font = "${ui.monoFont.family}:size=${toString ui.monoFont.size}";
              };

              cursor = {
                blink = true;
              };

              # colors = {
              #   alpha = 1.0;
              #   background = lib.removePrefix "#" ui.terminal.background;
              #   foreground = lib.removePrefix "#" ui.terminal.foreground;

              #   # ANSI colors (0-7)
              #   regular0 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 0);
              #   regular1 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 1);
              #   regular2 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 2);
              #   regular3 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 3);
              #   regular4 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 4);
              #   regular5 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 5);
              #   regular6 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 6);
              #   regular7 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 7);

              #   # Bright ANSI colors (8-15)
              #   bright0 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 8);
              #   bright1 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 9);
              #   bright2 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 10);
              #   bright3 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 11);
              #   bright4 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 12);
              #   bright5 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 13);
              #   bright6 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 14);
              #   bright7 = lib.removePrefix "#" (builtins.elemAt ui.terminal.palette 15);
              # };
            }
            // cfg.extraSettings;
        };

        # Set default terminal environment variables
        home.sessionVariables = {
          TERMINAL = "foot";
          TERMCMD = "foot"; # For compatibility with older tools
        };
      }
    ];
  };
}
