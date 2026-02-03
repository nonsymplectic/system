{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # --- GUI ---
    chromium
    qutebrowser
    protonmail-desktop
    keepassxc
    zed-editor

    # --- CLI TOOLS ---
    ps_mem # RAM usage
    htop # task viewer
    btop # task viewer
    neofetch # eyecandy welcome screen

    # --- FILE VIEWERS ----
    swayimg # wayland image viewer
    zathura # pdfs

    # --- CODE FORMATTERS ---
    nixpkgs-fmt # nix
    black # python
  ];
}
