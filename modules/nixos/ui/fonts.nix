{ config, lib, pkgs, ... }:

{
  /* ============================================================
     Fonts (system UI resources)
     ------------------------------------------------------------
     Shared UI assets used by terminal, editor, WM, etc.
     ============================================================ */

  fonts.packages = [
    (pkgs.nerdfonts.override {
      fonts = [ "JetBrainsMono" ];
    })
  ];
}
