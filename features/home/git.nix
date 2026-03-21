{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Michał Mikuta";
        email = "nonsymplectic@users.noreply.github.com";
      };

      init.defaultBranch = "main";

      pull.rebase = true;
      rebase.autoStash = true;

      fetch.prune = true;
      push.autoSetupRemote = true;

      diff.algorithm = "histogram";
      merge.conflictStyle = "zdiff3";
    };
  };

  home.packages = with pkgs; [git];
}
