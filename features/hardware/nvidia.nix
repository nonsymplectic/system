# NVIDIA GPU feature
# System-level only - enables NVIDIA drivers
{
  config,
  lib,
  ...
}: let
  cfg = config.features.nvidia;
in {
  options.features.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support";

    openDrivers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use open-source NVIDIA drivers";
    };

    powerManagement = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA power management";
    };
  };

  config = lib.mkIf cfg.enable {
    # OpenGL / graphics stack
    hardware.graphics.enable = true;

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = ["nvidia"];

    # Allow only the required unfree NVIDIA packages
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
        "nvidia-persistenced"
      ];

    # NVIDIA GPU setup
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = cfg.powerManagement;
      open = cfg.openDrivers;
      nvidiaSettings = true;
    };
  };
}
