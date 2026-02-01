{ config, lib, pkgs, ui, ... }:

let
  wm = config.my.wm;

  enabled = wm.enable && wm.launcher == "wofi";

  stripHash = s: lib.removePrefix "#" s;

  bg = stripHash ui.colors.background;
  fg = stripHash ui.colors.foreground;
  border = stripHash ui.colors.border;
  focus = stripHash ui.colors.focus;
  muted = stripHash (ui.colors.muted or ui.colors.foreground);

in
{
  /* ============================================================
     wofi (HM implementation module)
     ------------------------------------------------------------
     Purpose:
       - Enable + configure wofi via Home Manager (programs.wofi.*)
       - Self-gate on my.wm.enable && my.wm.launcher == "wofi"
       - Keep defaults; only:
           * set color via CSS (from UI tokens)
           * set sort order to alphabetical
     ============================================================ */


  /* ============================================================
     Configuration (selected only)
     ============================================================ */

  config = lib.mkIf enabled {

    /* ============================================================
       Enable wofi (installs + writes config/style via HM)
       ============================================================ */

    programs.wofi = {
      enable = true;

      # ----------------------------------------------------------
      # wofi(5): sort_order = default | alphabetical
      # ----------------------------------------------------------
      settings = {
        sort_order = "alphabetical";
        show_icons = false;
        insensitive = true;
        no_actions = true;
      };

      # ----------------------------------------------------------
      # Styling (wofi(7)): keep minimal + token-driven
      # ----------------------------------------------------------
      style = ''
        * {
          font-family: "${ui.monoFont.family}";
          font-size: ${toString ui.monoFont.size}px;
        }

        window {
          background-color: #${bg};
          color: #${fg};
          border: 0;
        }

        #input {
          background-color: #${bg};
          color: #${fg};
          border: 0;
        }

        #outer-box {
          background-color: #${border};
        }

        #entry {
          padding: 0;
          margin: 0;
        }

        #entry:selected {
          background-color: #${focus};
          color: #${bg};
        }

        #text {
          color: inherit;
        }

        #text:selected {
          color: inherit;
        }

        #scroll {
          background-color: #${bg};
        }

        #inner-box {
          background-color: #${bg};
        }

        #expander-box {
          background-color: #${bg};
          color: #${muted};
        }
      '';
    };
  };
}
