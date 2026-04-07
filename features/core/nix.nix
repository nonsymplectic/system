{
  nix = {
    settings.download-buffer-size = 128 * 1048577; # 128 MiB
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
