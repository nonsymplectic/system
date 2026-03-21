{
  pkgs,
  pkgsUnstable,
  catppuccin,
  config,
  ...
}:
{
  /*
    ============================================================
    Workstation profile (NixOS layer)
    ------------------------------------------------------------
    Role profile for a workstation-like machine.
    - System-level imports (users, DM, secrets)
    - Home Manager module wiring (user environment)
    - Minimal system baseline (net + session packages)
    ============================================================
  */

  /*
    ============================================================
    NixOS module imports
    ============================================================
  */

  imports = [
    # Inherits from minimal.nix (includes features/core with UI options)
    ../profiles/minimal.nix

    # System features
    ../modules/nixos/core/unfree-packages.nix # Allow unfree packages
    ../modules/nixos/ui/fonts.nix # Font resources
    ../modules/nixos/services/ly.nix # Display manager
    ../modules/nixos/core/agenix.nix # Secrets management

    # Desktop features (dendritic pattern)
    ../features/desktop/sway.nix
    ../features/desktop/waybar.nix
    ../features/desktop/foot.nix
    ../features/desktop/wofi.nix
  ];

  /*
    ============================================================
    Home Manager
    ------------------------------------------------------------
    user-level home-manager settings belong in hosts/<hostname>/users.nix
    ============================================================
  */
  # Home Manager configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Only pass pkgsUnstable - UI tokens accessible via config.my.ui
  home-manager.extraSpecialArgs = {
    inherit pkgsUnstable;
  };

  home-manager.sharedModules = [
    # Catppuccin theme support
    catppuccin.homeModules.catppuccin

    # Core user configuration
    ../modules/home/core/shell.nix # Shell (bash/zsh)
    ../modules/home/core/ssh.nix # SSH config
    ../modules/home/core/git.nix # Git config

    # Desktop theming and customization
    ../modules/home/input-methods.nix # Input methods
    ../modules/home/desktop/theme.nix # GTK/Qt theming

    # User applications and services
    ../modules/home/default-apps.nix # Default applications
    ../modules/home/desktop-entries.nix # Desktop entries
    ../modules/home/packages.nix # User packages
    ../modules/home/services.nix # User services
  ];

  # Enable dendritic desktop features
  features.sway.enable = true;
  features.waybar.enable = true;
  features.foot.enable = true;
  features.wofi.enable = true;
}
