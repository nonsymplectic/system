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
    # Host-defined UI token surface (my.ui)
    ../modules/common/ui.nix

    # Font resources
    ../modules/nixos/ui/fonts.nix

    # Declares primaryUser plumbing
    ../modules/nixos/core/primary-user.nix

    # Display manager is system-level
    ../modules/nixos/services/ly.nix

    # Secrets management (agenix)
    ../modules/nixos/core/agenix.nix
  ];


  /* ============================================================
     Home Manager wiring
     ------------------------------------------------------------
     Only wires HM modules from the NixOS layer.
     All my.* options must be set inside HM scope (via HM modules).
     ============================================================ */
  home-manager.extraSpecialArgs = {
    # Pass host-defined UI tokens into Home Manager scope.
    ui = config.my.ui;
  };

  home-manager.sharedModules = [
    # WM implementation + policy (HM scope)
    ../modules/home/wm.nix
    ../profiles/home/workstation.nix

    # User-level applications
    ../modules/home/apps.nix

    # Core developer-facing CLI tools
    ../modules/home/core/devtools.nix

    # Terminal emulator (foot)
    ../modules/home/core/foot.nix

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


  /* ============================================================
     Display manager sessions
     ------------------------------------------------------------
     Ensure the WM is available as a login session.
     ============================================================ */

  services.displayManager.sessionPackages = with pkgs; [
    sway
  ];
}
