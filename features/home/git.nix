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

      user.signingkey = "A95E6DE301FBDF0FEAE8B9422AED34C030B29CC2";
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.format = "openpgp";
    };
  };

  home.packages = with pkgs; [git];
}
