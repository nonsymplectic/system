{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;

    userName = "Michał Mikuta";
    userEmail = "nonsymplectic@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";

      pull.rebase = true;
      rebase.autoStash = true;

      fetch.prune = true;
      push.autoSetupRemote = true;

      diff.algorithm = "histogram";
      merge.conflictStyle = "zdiff3";
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      user = "git";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
      identitiesOnly = true;
    };
  };

  home.packages = with pkgs; [ git gh ];
}

