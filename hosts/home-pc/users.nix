{
  lib,
  config,
  ...
}: {
  # --- Primary user ---
  my.primaryUser = "michal";

  users.users.michal = {
    isNormalUser = true;
    extraGroups =
      ["wheel"] # Enable ‘sudo’ for the user.
      ++ lib.optionals config.features.virtualization.enable [
        "libvirtd"
        "kvm"
      ]; # Enable virtualization support
  };

  # --- Home manager ---
  home-manager.users.michal = {
    home.username = "michal";
    home.homeDirectory = "/home/michal";
    home.stateVersion = "25.11";

    xdg.enable = true;
    xdg.mimeApps.enable = true;
    programs.home-manager.enable = true;
  };

  # --- Add further users here ---
}
