{ lib, pkgs, ui, desktop, ... }:

let
  enabled =
    desktop.enable
    && desktop.launcher.name == "wofi";

  stripHash = s: lib.removePrefix "#" s;

  bg = stripHash ui.colors.background;
  fg = stripHash ui.colors.foreground;
  border = stripHash ui.colors.border;
  focus = stripHash ui.colors.focus;
  muted = stripHash (ui.colors.muted or ui.colors.foreground);
in
{
  /*
    Wofi (Home Manager plugin)

    Responsibilities:
      - Self-gate on normalized desktop payload (`desktop.*`).
      - Enable + configure wofi via Home Manager (programs.wofi.*).
      - Styling derives from immutable UI tokens (`ui.*`).
  */

  config = lib.mkIf enabled {
    programs.wofi = {
      enable = true;

      # wofi(5): sort_order = default | alphabetical
      settings = {
        sort_order = "alphabetical";
        show_icons = false;
        insensitive = true;
        no_actions = true;
        term = "${desktop.terminal.command}";
      };

      # wofi(7): minimal + token-driven
      style = ''
        * {
          font-family: "${ui.monoFont.family}";
          font-size: ${toString ui.monoFont.sizePx}px;
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
