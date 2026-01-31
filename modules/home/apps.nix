{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --- GUI ---
    chromium
    keepassxc
    zed-editor

    # --- CLI TOOLS ---
    ps_mem
    neofetch

    # --- FILE VIEWERS ----
    swayimg
    zathura
  ];
}
