let
  home-pc = "age1ut4vhgwvnkng46zx0et7a7ptcfaxpsgjj94mrqmkzl7z706dafrqzklrxx"; # home-pc public key
  #  laptop = "age1...";   # paste laptop public key
in {
  "secrets/github_id_ed25519_github.age".publicKeys = [home-pc]; #don't forget to add laptop later
  "secrets/borgbackup_passphrase.age".publicKeys = [home-pc]; # Shared passphrase for borg repository
  "secrets/borgbackup_b2_env.age".publicKeys = [home-pc]; # Backblaze B2 credentials
  "secrets/rclone_conf.age".publicKeys = [home-pc]; # Rclone configuration for B2
}
