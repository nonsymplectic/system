let
  home-pc = "age1ut4vhgwvnkng46zx0et7a7ptcfaxpsgjj94mrqmkzl7z706dafrqzklrxx"; # home-pc public key
  laptop = "age1y4esvm73q2lgvf29dkzvs8plkj0dm0pxw605k4k9u6zu89ps6ags0qq929"; # laptop public key

  all-machines = [home-pc laptop];
in {
  "secrets/gpg_private_key.age".publicKeys = all-machines; # gpg key
  "secrets/id_ed25519_github.age".publicKeys = all-machines; # github
  "secrets/borgbackup_passphrase.age".publicKeys = all-machines; # Shared passphrase for borg repository
  "secrets/borgbackup_b2_env.age".publicKeys = all-machines; # Backblaze B2 credentials
  "secrets/rclone_conf.age".publicKeys = all-machines; # Rclone configuration for B2
  "secrets/id_ed25519_late.age".publicKeys = all-machines; # ssh key for late.sh
}
