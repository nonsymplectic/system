{ pkgs, pkgsUnstable, ... }:

{
  programs = {
    # --- WEB BROWSERS ---
    chromium.enable = true;
    qutebrowser.enable = true;

    # --- CLI TOOLS ---
    btop.enable = true;

    # --- FILE VIEWERS ---
    zathura.enable = true;

    # --- IDES ---
    zed-editor = {
      enable = true;
      package = pkgsUnstable.zed-editor;
    };
  };

  home.packages =
    (with pkgs; [
      pulseaudioFull

      # --- WEB BROWSERS ---
      tor-browser

      # --- GUI ---
      blueman
      keepassxc
      dino
      calibre
      zotero

      # --- CLI TOOLS ---
      ps_mem # RAM usage
      htop # task viewer
      neofetch # eyecandy welcome screen

      # --- FILE VIEWERS ----
      swayimg # wayland image viewer

      # --- CODE FORMATTERS ---
      nixpkgs-fmt # nix
      black # python
    ])
    ++
    (with pkgsUnstable; [
      # --- GUI ---
      protonmail-desktop
    ]);
}
