# Core system packages
# Essential tools available to all users on all hosts
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nix-search
    vim
    wget
    git
    tree
    openssh

    # Shorthand for rebuilding system config
    (writeShellScriptBin "system-rebuild" ''
      exec nixos-rebuild switch --flake ".#$(hostname)"
    '')
  ];
}
