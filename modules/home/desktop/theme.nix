{ catppuccin, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "latte";
    accent = "pink";

    cursors = {
      enable = true;
      accent = "pink";
    };

    sway.enable = false;
    swaylock.enable = false;
    waybar.enable = false;
    foot.enable = false;
  };
}
