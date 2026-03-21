{...}: {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./users.nix

    # Shared role profile
    ../../profiles/workstation.nix
  ];

  # Host identity
  networking.hostName = "laptop";
  time.timeZone = "Europe/Zurich";
}
