# Fuzzel launcher feature
# Home Manager only - no system-level configuration needed
{
  config,
  lib,
  ...
}: let
  cfg = config.features.fuzzel;
  ui = config.my.ui;

  stripHash = s: lib.removePrefix "#" s;
  withAlpha = hex: "${stripHash hex}ff";

  bg = withAlpha ui.colors.background;
  fg = withAlpha ui.colors.foreground;
  border = withAlpha ui.colors.border;
  focus = withAlpha ui.colors.focus;
  muted = withAlpha (ui.colors.muted or ui.colors.foreground);
in {
  options.features.fuzzel = {
    enable = lib.mkEnableOption "Fuzzel launcher";

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra settings to pass to programs.fuzzel.settings";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager configuration
    home-manager.sharedModules = [
      {
        programs.fuzzel = {
          enable = true;

          settings =
            {
              main = {
                terminal = "foot"; # Hardcoded - will be overridden if needed
                font = "${ui.monoFont.family}:size=${toString ui.monoFont.size}";
                icons-enabled = false;
                show-actions = false;

                lines = 10;
                width = 40;
                horizontal-pad = 12;
                vertical-pad = 8;
                inner-pad = 6;
              };

              colors = {
                background = bg;
                text = fg;
                prompt = fg;
                input = fg;
                placeholder = muted;
                selection = focus;
                selection-text = bg;
                selection-match = bg;
                match = focus;
                border = focus;
              };

              border = {
                width = 2;
                radius = 12;
              };
            }
            // cfg.extraSettings;
        };
      }
    ];
  };
}
