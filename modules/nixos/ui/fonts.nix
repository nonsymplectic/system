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
  fonts.fontconfig.enable = true;

  # Optional but commonly useful: exposes a font directory in the system profile.
  fonts.fontDir.enable = true;
}
