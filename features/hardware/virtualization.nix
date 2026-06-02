{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.virtualization;
in {
  options.features.virtualization.enable =
    lib.mkEnableOption "Virtualization support";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;

    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virtiofsd
    ];
  };
}
