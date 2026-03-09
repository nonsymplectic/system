{ pkgs, ... }:

{
  /* ============================================================
     Fonts (system UI resources)
     ------------------------------------------------------------
     Shared UI assets used by terminal, editor, WM, etc.
     Provisioned at the NixOS layer; consumed by HM apps.
     ============================================================ */

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
  ];

  # Make fonts discoverable system-wide via fontconfig.
  fonts.fontconfig =
    {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans" "Noto Sans CJK SC" "Noto Sans CJK TC" "Noto Sans CJK JP" "Noto Sans CJK KR" ];
        serif = [ "Noto Serif" "Noto Serif CJK SC" "Noto Serif CJK TC" "Noto Serif CJK JP" "Noto Serif CJK KR" ];
        monospace = [ "Noto Sans Mono CJK SC" "Noto Sans Mono CJK TC" "Noto Sans Mono CJK JP" "Noto Sans Mono CJK KR" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

  # Optional but commonly useful: exposes a font directory in the system profile.
  fonts.fontDir.enable = true;
}
