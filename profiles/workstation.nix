{ pkgs, config, ... }:

{
  /* ============================================================
     Workstation profile (NixOS layer)
     ------------------------------------------------------------
     Role profile for a workstation-like machine.
     - System-level imports (users, DM, secrets)
     - Home Manager module wiring (user environment)
     - Minimal system baseline (net + session packages)
     ============================================================ */


  /* ============================================================
     NixOS module imports
     ============================================================ */

  imports = [
    # default UI token surface (my.ui)
    ../options/ui.nix

    # default desktop token surface (my.desktop)
    ../options/desktop.nix

    # Declares WM token surface (my.wm)
    ../modules/common/wm.nix

    # Declares primaryUser plumbing
    ../modules/nixos/core/primary-user.nix

    # Font resources
    ../modules/nixos/ui/fonts.nix

    # Installs Display Manager
    ../modules/nixos/services/ly.nix

    # Some WMs need a DM hotfix
    ../modules/nixos/ui/sway.nix

    # Secrets management (agenix)
    ../modules/nixos/core/agenix.nix
  ];


  /* ============================================================
     Home Manager wiring
     ------------------------------------------------------------
     Only wires HM modules from the NixOS layer.
     ============================================================ */



  home-manager.sharedModules = [
    # Shell
    ../modules/home/core/shell.nix

    # WM implementation + policy (HM scope)
    ../options/desktop.nix
    ../modules/home/desktop/interface.nix

    # User-level applications
    ../modules/home/apps.nix

    # Core developer-facing CLI tools
    ../modules/home/core/devtools.nix

    # Git configuration
    ../modules/home/core/git.nix
  ];

  /* ============================================================
     Networking baseline
     ============================================================ */

  networking.networkmanager.enable = true;


  /* ============================================================
     Minimal system packages
     ------------------------------------------------------------
     System-level tools available to all users.
     User applications should go through Home Manager.
     ============================================================ */

  environment.systemPackages = with pkgs; [
    nix-search
    vim
    wget
    tree
    htop
    git
  ];


  /* ============================================================
     XDG / portal integration
     ------------------------------------------------------------
     Required by Home Manager NixOS module when useUserPackages=true
     and xdg.portal is enabled in HM. Links portal + desktop configs
     into the system profile for discovery.
     ============================================================ */

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
}
