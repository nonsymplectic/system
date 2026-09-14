{...}: {
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "green";

    cursors = {
      enable = false;
      accent = "green";
    };

    sway.enable = false;
    fuzzel.enable = false;
    mako.enable = false;
    swaylock.enable = false;
    waybar.enable = false;
    mpv.enable = false;

    librewolf.force = true;
  };

  gtk = {
    enable = true;
  };

  qt = {
    enable = true;
    style.name = "kvantum";
  };
}
