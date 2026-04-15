{...}: {
  catppuccin = {
    enable = true;
    flavor = "latte";
    accent = "pink";

    cursors = {
      enable = false;
      accent = "pink";
    };

    sway.enable = false;
    fuzzel.enable = false;
    mako.enable = false;
    swaylock.enable = false;
    waybar.enable = false;
  };

  gtk = {
    enable = true;
  };

  qt = {
    enable = true;
    style.name = "kvantum";
  };
}
