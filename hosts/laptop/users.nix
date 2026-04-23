# Laptop user configuration
{...}: {
  # Primary user setup
  my.primaryUser = "michal";

  users.users.michal = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  # Enable Home Manager for primary user
  home-manager.users.michal = {
    home.username = "michal";
    home.homeDirectory = "/home/michal";
    home.stateVersion = "25.11";

    xdg.enable = true;
    xdg.mimeApps.enable = true;
    programs.home-manager.enable = true;
  };
}
