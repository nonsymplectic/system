# Wofi launcher feature
# Home Manager only - no system-level configuration needed
{
  config,
  lib,
  ...
}: let
  cfg = config.features.wofi;
  ui = config.my.ui;

  stripHash = s: lib.removePrefix "#" s;
  bg = stripHash ui.colors.background;
  fg = stripHash ui.colors.foreground;
  border = stripHash ui.colors.border;
  focus = stripHash ui.colors.focus;
  muted = stripHash (ui.colors.muted or ui.colors.foreground);
in {
  options.features.wofi = {
    enable = lib.mkEnableOption "Wofi launcher";

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra settings to pass to programs.wofi.settings";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration
    home-manager.sharedModules = [
      {
        programs.wofi = {
          enable = true;

          settings =
            {
              sort_order = "alphabetical";
              show_icons = false;
              insensitive = true;
              no_actions = true;
              term = "foot"; # Hardcoded - will be overridden if needed
            }
            // cfg.extraSettings;

          style = ''
            * {
              font-family: "${ui.monoFont.family}";
              font-size: ${toString ui.monoFont.sizePx}px;
            }

            window {
              background-color: #${bg};
              color: #${fg};
              border: 0;
            }

            #input {
              background-color: #${bg};
              color: #${fg};
              border: 0;
            }

            #outer-box {
              background-color: #${border};
            }

            #entry {
              padding: 0;
              margin: 0;
            }

            #entry:selected {
              background-color: #${focus};
              color: #${bg};
            }

            #text {
              color: inherit;
            }

            #text:selected {
              color: inherit;
            }

            #scroll {
              background-color: #${bg};
            }

            #inner-box {
              background-color: #${bg};
            }

            #expander-box {
              background-color: #${bg};
              color: #${muted};
            }
          '';
        };
      }
    ];
  };
}
