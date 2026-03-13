{
  pkgs,
  pkgsUnstable,
  ...
}:
{
  # --- HOME MANAGER ---
  programs = {
    # --- WEB BROWSERS ---
    chromium.enable = true;
    qutebrowser.enable = true;

    # --- CLI TOOLS ---
    btop.enable = true;

    # --- FILE VIEWERS ---
    zathura.enable = true;
    mpv.enable = true;
    imv.enable = true;

    # --- GUI ---
    anki.enable = true;

    # --- EDITORS ---
    neovim.enable = true;

    zed-editor = {
      enable = true;
      package = pkgsUnstable.zed-editor;
      extensions = [ "nix" ];
      extraPackages = [
        pkgs.nixd
        pkgs.nil
      ];
    };
  };

  # --- NON HOME MANAGER ---
  home.packages =
    (with pkgs; [
      pulseaudioFull
      dconf # for GTK

      # --- WEB BROWSERS ---
      tor-browser

      # --- GUI ---
      blueman
      keepassxc
      dino
      calibre

      # --- CLI TOOLS ---
      ps_mem # RAM usage
      htop # task viewer
      neofetch # eyecandy welcome screen
      claude-code

      # --- FILE VIEWERS ----
      swayimg # wayland image viewer

      # --- CODE FORMATTERS ---
      alejandra # nix
      black # python
    ])
    ++ (with pkgsUnstable; [
      # --- GUI ---
      protonmail-desktop
      zotero
    ]);
}
