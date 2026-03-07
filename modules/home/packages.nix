{ pkgs, pkgsUnstable, ... }:
{
  home.packages =
    (with pkgs; [
      pulseaudioFull

      # --- GUI ---
      blueman
      chromium
      qutebrowser
      keepassxc
      dino
      calibre
      zotero

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
    ])
    ++
    (with pkgsUnstable; [
      # --- GUI ---
      zed-editor
      protonmail-desktop
    ]);
}
