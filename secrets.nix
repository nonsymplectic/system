let
  home-pc = "age1ut4vhgwvnkng46zx0et7a7ptcfaxpsgjj94mrqmkzl7z706dafrqzklrxx"; # home-pc public key
  laptop = "age1y4esvm73q2lgvf29dkzvs8plkj0dm0pxw605k4k9u6zu89ps6ags0qq929"; # laptop public key
in {
  "secrets/github_id_ed25519_github.age".publicKeys = [
    home-pc
    laptop
  ]; # don't forget to add laptop later
  "secrets/borgbackup_passphrase.age".publicKeys = [
    home-pc
    laptop
  ]; # Shared passphrase for borg repository
  "secrets/borgbackup_b2_env.age".publicKeys = [
    home-pc
    laptop
  ]; # Backblaze B2 credentials
  "secrets/rclone_conf.age".publicKeys = [
    home-pc
    laptop
  ]; # Rclone configuration for B2
}
