{ config, lib, pkgs, ui, wm, ... }:

let
  enabled = wm.enable && wm.terminal == "foot";

  stripHash = s: lib.removePrefix "#" s;

  p = i: stripHash (builtins.elemAt ui.terminal.palette i);

in
{
  /* ============================================================
     foot (HM implementation module)
     ------------------------------------------------------------
     Purpose:
       - Enable + configure foot via Home Manager (programs.foot.*)
       - Self-gate on my.wm.enable && my.wm.terminal == "foot"
       - Derive colors / font from UI tokens
     ============================================================ */


  /* ============================================================
     Configuration (selected only)
     ============================================================ */

  config = lib.mkIf enabled {

    /* ============================================================
       Enable foot (installs + writes foot.ini via HM)
       ============================================================ */

    programs.foot = {
      enable = true;

      settings = {
        main = {
          term = "foot-direct";
          font = "${ui.monoFont.family}:size=${toString ui.monoFont.size}";
        };

        cursor = {
          blink = true;
        };

        colors = {
          foreground = stripHash ui.terminal.foreground;
          background = stripHash ui.terminal.background;

          # foot expects "cursor=<fg> <bg>"
          cursor = "${stripHash ui.terminal.background} ${stripHash ui.terminal.cursor}";

          regular0 = p 0;
          regular1 = p 1;
          regular2 = p 2;
          regular3 = p 3;
          regular4 = p 4;
          regular5 = p 5;
          regular6 = p 6;
          regular7 = p 7;

          bright0 = p 8;
          bright1 = p 9;
          bright2 = p 10;
          bright3 = p 11;
          bright4 = p 12;
          bright5 = p 13;
          bright6 = p 14;
          bright7 = p 15;
        };
      };
    };
  };
}
