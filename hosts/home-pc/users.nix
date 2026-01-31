{ ... }:
{
  users.users.michal = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.michal = {
    home.username = "michal";
    home.homeDirectory = "/home/michal";
    home.stateVersion = "25.11";

    programs.home-manager.enable = true;
  };
}
