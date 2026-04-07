{
  nix = {
    settings.download-buffer-size = 32 * 1048577; # 32MiB
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
