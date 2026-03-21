# Core features - auto-imported for all hosts
# These modules provide baseline functionality that every host needs
{...}: {
  imports = [
    ./ui-options.nix # UI tokens (my.ui.*)
    ./nix.nix # Nix settings (auto-optimize, GC)
    ./primary-user.nix # Primary user option declaration
    ./network.nix # NetworkManager
    ./packages.nix # Essential system packages
  ];
}
