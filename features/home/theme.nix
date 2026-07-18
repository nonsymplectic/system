{...}: {
  catppuccin = {
    enable = true;
    flavor = "latte";
    accent = "blue";

    cursors = {
      enable = false;
      accent = "blue";
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
