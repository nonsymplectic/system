let
  home-pc = "age1ut4vhgwvnkng46zx0et7a7ptcfaxpsgjj94mrqmkzl7z706dafrqzklrxx";   # home-pc public key
#  laptop = "age1...";   # paste laptop public key
in
{
  "secrets/github_id_ed25519_github.age".publicKeys = [ home-pc ]; #don't forget to add laptop later
}

