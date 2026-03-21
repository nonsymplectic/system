# Input methods feature
# Home Manager only - fcitx5 and other input method frameworks
{
  config,
  lib,
  ...
}: let
  cfg = config.features.input-methods;
in {
  options.features.input-methods = {
    enable = lib.mkEnableOption "Input method framework";

    type = lib.mkOption {
      type = lib.types.enum ["fcitx5" "ibus"];
      default = "fcitx5";
      description = "Input method framework to use";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        i18n.inputMethod = {
          enabled = cfg.type;
          # Add framework-specific configuration here if needed
        };
      }
    ];
  };
}
