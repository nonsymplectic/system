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
    # inherits from minimal.nix
    ../profiles/minimal.nix

    # Allow unfree
    ../modules/nixos/core/unfree-packages.nix

    # default UI token surface (my.ui)
    ../options/ui.nix

    # default desktop token surface (my.desktop)
    ../options/desktop.nix

    # Font resources
    ../modules/nixos/ui/fonts.nix

    # Installs Display Manager
    ../modules/nixos/services/ly.nix

    # Some WMs need hotfixes
    ../modules/nixos/ui/wm-setup.nix

    # Secrets management (agenix)
    ../modules/nixos/core/agenix.nix
  ];

  /*
    ============================================================
    Home Manager
    ------------------------------------------------------------
    user-level home-manager settings belong in hosts/<hostname>/users.nix
    ============================================================
  */
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit pkgsUnstable catppuccin;
    uiPolicy = config.my.ui;
    desktopPolicy = config.my.desktop;
  };

  home-manager.sharedModules = [
    # --- CORE ---
    ../modules/home/core/shell.nix # shell
    ../modules/home/core/ssh.nix # ssh config
    ../modules/home/core/git.nix # git config

    # --- DESKTOP ENVIRONMENT ---
    ../modules/home/desktop/interface.nix
    ../modules/home/input-methods.nix

    catppuccin.homeModules.catppuccin
    ../modules/home/desktop/theme.nix

    # --- GENERIC USER LEVEL ---
    ../modules/home/desktop-entries.nix
    ../modules/home/packages.nix
    ../modules/home/services.nix
  ];

  /*
    ============================================================
    XDG / portal integration
    ------------------------------------------------------------
    Required by Home Manager NixOS module when useUserPackages=true
    and xdg.portal is enabled in HM. Links portal + desktop configs
    into the system profile for discovery.
    ============================================================
  */

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
}
