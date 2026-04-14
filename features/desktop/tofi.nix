# Tofi launcher feature
# Home Manager only - no system-level configuration needed
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.tofi;
  ui = config.my.ui;

  stripHash = s: lib.removePrefix "#" s;

  bg = ui.colors.background;
  fg = ui.colors.foreground;
  border = ui.colors.border;
  focus = ui.colors.focus;
  muted = ui.colors.muted or ui.colors.foreground;

  defaultSettings = {
    # typography
    font = ui.monoFont.family;
    font-size = ui.monoFont.sizePx;

    # prompt / input
    prompt-text = "run: ";
    prompt-padding = 0;
    placeholder-text = "";
    text-cursor-style = "bar";
    text-cursor-corner-radius = 0;

    num-results = 0;
    result-spacing = 0;
    horizontal = false;
    min-input-width = 0;

    # colors
    background-color = bg;
    text-color = fg;

    prompt-background = "#00000000";
    placeholder-color = "${fg}A8";
    placeholder-background = "#00000000";
    input-background = "#00000000";

    default-result-background = "#00000000";
    selection-color = focus;
    selection-background = "#00000000";
    selection-match-color = "#00000000";

    # window chrome
    outline-width = 1;
    outline-color = focus;
    border-width = 0;
    border-color = focus;
    corner-radius = 1;

    padding-top = 0;
    padding-bottom = 0;
    padding-left = 0;
    padding-right = 0;

    clip-to-padding = true;
    scale = true;
    anchor = "center";

    # behavior
    terminal = "${pkgs.foot}/bin/foot";
    drun-launch = false;
    auto-accept-single = true;
  };

  tofiFormat = lib.generators.toKeyValue {
    mkKeyValue = key: value: let
      rendered =
        if builtins.isBool value
        then
          if value
          then "true"
          else "false"
        else if builtins.isInt value || builtins.isFloat value
        then toString value
        else ''"${toString value}"'';
    in "${key} = ${rendered}";
  };
in {
  options.features.tofi = {
    enable = lib.mkEnableOption "Tofi launcher";

    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra settings to pass to tofi via ~/.config/tofi/config";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        home.packages = [pkgs.tofi];

        xdg.configFile."tofi/config".text =
          tofiFormat (defaultSettings // cfg.extraSettings);
      }
    ];
  };
}
