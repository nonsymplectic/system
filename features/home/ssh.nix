# ssh.nix
{config, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "auto";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "5m";
    };

    matchBlocks."github.com" = {
      user = "git";
      identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
      identitiesOnly = true;
    };
  };
}
