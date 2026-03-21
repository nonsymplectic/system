# Flake-wide baseline configuration
# Applied to all hosts automatically
{...}: {
  # Enable flakes and nix-command
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # NixOS release version (never change after initial install)
  system.stateVersion = "25.11";

  # Default boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
