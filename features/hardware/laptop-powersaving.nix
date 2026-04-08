# Laptop Powersaving feature
{
  config,
  lib,
  ...
}: let
  cfg = config.features.laptop-powersaving;
in {
  options.features.laptop-powersaving = {
    enable = lib.mkEnableOption "Laptop powersaving support";
  };

  config = lib.mkIf cfg.enable {
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          turbo = "always";
        };
      };
    };
  };
}
