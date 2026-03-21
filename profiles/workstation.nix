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
    ../features/system/unfree-packages.nix
    ../features/system/fonts.nix
    ../features/system/ly-dm.nix
    ../features/system/agenix.nix

    # Desktop features (dendritic pattern)
    ../features/desktop/sway.nix
    ../features/desktop/waybar.nix
    ../features/desktop/foot.nix
    ../features/desktop/wofi.nix

    # Hardware features (optional, enabled per-host)
    ../features/hardware/nvidia.nix
    ../features/hardware/bluetooth.nix

    # App features
    ../features/apps/browsers.nix
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
    ../features/home/shell.nix
    ../features/home/ssh.nix
    ../features/home/git.nix
    ../features/home/theme.nix

    # Desktop theming and customization
    ../modules/home/input-methods.nix

    # User applications and services
    ../modules/home/default-apps.nix
    ../modules/home/desktop-entries.nix
    ../modules/home/packages.nix
    ../modules/home/services.nix
  ];

  # Enable features
  features.sway.enable = true;
  features.waybar.enable = true;
  features.foot.enable = true;
  features.wofi.enable = true;
  features.browsers.enable = true;
}
