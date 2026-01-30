{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./users.nix
    ./swap.nix
    ../../profiles/minimal.nix
  ];

  networking.hostName = "nixos";
  time.timeZone = "Europe/Zurich";

  # Host-specific boot policy
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
