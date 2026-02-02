{ ... }:
{
  # --- Primary user ---
  my.primaryUser = "michal";

  users.users.michal = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # --- Home manager ---
  home-manager.users.michal = {
    home.username = "michal";
    home.homeDirectory = "/home/michal";
    home.stateVersion = "25.11";

    programs.home-manager.enable = true;
  };

  # --- Add further users here ---
}
