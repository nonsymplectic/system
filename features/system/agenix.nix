{
  config,
  inputs,
  pkgs,
  ...
}: let
  user = config.my.primaryUser;
  u = config.users.users.${user};
  home = u.home;
  group = u.group;
in {
  age.identityPaths = ["/etc/agenix/host.agekey"];

  # Install agenix CLI for managing secrets
  environment.systemPackages = [inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default];

  systemd.tmpfiles.rules = [
    "d ${home}/.ssh 0700 ${user} ${group} -"
  ];

  age.secrets.github_ssh_key = {
    file = ../../secrets/id_ed25519_github.age;
    owner = user;
    inherit group;
    mode = "0600";
    path = "${home}/.ssh/id_ed25519_github";
  };
  age.secrets.late_ssh_key = {
    file = ../../secrets/id_ed25519_late.age;
    owner = user;
    inherit group;
    mode = "0600";
    path = "${home}/.ssh/id_ed25519_late";
  };

  age.secrets.gpg_private_key = {
    file = ../../secrets/gpg_private_key.age;
    owner = user;
    inherit group;
    mode = "0600";
  };
}
