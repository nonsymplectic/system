{
  pkgsUnstable,
  catppuccin,
  ...
}: {
  /*
  ============================================================
  Workstation profile (NixOS layer)
  ------------------------------------------------------------
  Role profile for a workstation-like machine.
  Imports all desktop and application features, enables them.
  ============================================================
  */

  imports = [
    # Inherits from minimal.nix (includes features/core)
    ../profiles/minimal.nix

    # System features
    ../features/system/unfree-packages.nix
    ../features/system/fonts.nix
    ../features/system/tuigreet.nix
    ../features/system/agenix.nix
    ../features/system/borgbackup.nix

    # Desktop features
    ../features/desktop/sway.nix
    ../features/desktop/waybar.nix
    ../features/desktop/foot.nix
    ../features/desktop/wofi.nix
    ../features/desktop/wlsunset.nix
    ../features/desktop/input-methods.nix
    ../features/desktop/desktop-support.nix

    # Hardware features (enabled per-host)
    ../features/hardware/nvidia.nix
    ../features/hardware/bluetooth.nix
    ../features/hardware/laptop-powersaving.nix

    # App features
    ../features/apps/browsers.nix
    ../features/apps/editors.nix
    ../features/apps/viewers.nix
    ../features/apps/productivity.nix
    ../features/apps/communication.nix
    ../features/apps/security.nix
    ../features/apps/cli-tools.nix
    ../features/apps/formatters.nix
    ../features/apps/utilities.nix
    ../features/apps/keepassxc-sync.nix
    ../features/apps/minecraft.nix
  ];

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
  ];

  # Enable desktop features
  features.sway.enable = true;
  features.waybar.enable = true;
  features.foot.enable = true;
  features.wofi.enable = true;
  features.wlsunset.enable = true;
  # features.input-methods.enable = false; # Disabled by default
  features.desktop-support.enable = true;

  # Enable application features
  features.browsers.enable = true;
  features.editors.enable = true;
  features.viewers.enable = true;
  features.productivity.enable = true;
  features.communication.enable = true;
  features.security.enable = true;
  features.cli-tools.enable = true;
  features.formatters.enable = true;
  features.utilities.enable = true;
}
