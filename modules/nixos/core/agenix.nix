{ config, ... }:
let
  user = config.my.primaryUser;
  u = config.users.users.${user};
  home = u.home;
  group = u.group;
in
{
  age.identityPaths = [ "/etc/agenix/host.agekey" ];

  systemd.tmpfiles.rules = [
    "d ${home}/.ssh 0700 ${user} ${group} -"
  ];

  age.secrets.github_ssh_key = {
    file = ../../../secrets/github_id_ed25519_github.age;
    owner = user;
    inherit group;
    mode = "0600";
    path = "${home}/.ssh/id_ed25519_github";
  };
}

