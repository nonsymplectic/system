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

  # Feature configuration
  # Laptops might want smaller fonts, different bar position, etc.
  # Example overrides:
  # my.ui.font.size = 14;
  # features.waybar.position = "top";
}
