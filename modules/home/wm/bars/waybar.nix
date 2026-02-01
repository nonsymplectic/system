{ config, lib, pkgs, ui, ... }:

let
  wm = config.my.wm;

  enabled = wm.enable && wm.bar.enable && wm.bar.backend == "waybar";

  stripHash = s: lib.removePrefix "#" s;

  bg = stripHash ui.colors.background;
  fg = stripHash ui.colors.foreground;
  focus = stripHash ui.colors.focus;

  batScript = pkgs.writeShellScript "waybar-bat" ''
    set -eu
    bat="$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1 || true)"
    [ -n "$bat" ] || exit 0
    cap="$(cat "$bat/capacity" 2>/dev/null || true)"
    [ -n "$cap" ] || exit 0
    printf 'BAT: %s%% |\n' "$cap"
  '';
in
{
  /* ============================================================
     waybar (HM implementation module)
     ------------------------------------------------------------
     Purpose:
       - Enable + configure Waybar via Home Manager (programs.waybar.*)
       - Self-gate on my.wm.enable && my.wm.bar.enable && my.wm.bar.backend
       - Keep defaults; only:
           * set colors (from UI tokens)
           * set font (from UI tokens, NOT scaled)
           * remove layout padding/spacing (tight like sway)
       - Provide my.wm.bar.command for the selected bar backend
     ============================================================ */


  /* ============================================================
     Configuration (selected only)
     ============================================================ */

  config = lib.mkIf enabled {

    # ----------------------------------------------------------
    # Provide bar command (selected bar module owns this)
    # ----------------------------------------------------------
    my.wm.bar.command = lib.mkDefault "waybar";


    /* ============================================================
       Enable Waybar (installs + writes config/style via HM)
       ============================================================ */

    programs.waybar = {
      enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = wm.bar.position;

          # Tight: no inter-module spacing.
          spacing = 0;

          modules-left = [ "sway/workspaces" ];
          modules-center = [ ];
          modules-right = [
            "network"
            "custom/bat"
            "disk"
            "memory"
            "clock"
          ];

          network = {
            interval = 45;
            format-wifi = "NET: WIFI |";
            format-ethernet = "NET: ETH |";
            format-disconnected = "NET: -- |";
            tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}";
            tooltip-format-ethernet = "{ifname}\n{ipaddr}";
            tooltip-format-disconnected = "disconnected";
          };

          "custom/bat" = {
            exec = "${batScript}";
            interval = 45;
            return-type = "plain";
            hide-empty-text = true;
            tooltip = false;
          };

          disk = {
            interval = 90;
            path = "/";
            unit = "GiB";
            format = "/: {specific_used:0.2f}/{specific_total:0.2f}GiB |";
            tooltip = false;
          };

          memory = {
            interval = 45;
            format = "MEM: {used:0.2f}/{total:0.2f}GiB |";
            tooltip = false;
          };

          clock = {
            interval = 45;
            format = "{:%a %F %H:%M}";
            tooltip = false;
          };
        };
      };

      style = ''
        * {
          font-family: "${ui.font.family}";
          font-size: ${toString ui.font.size};
          border: none;
          border-radius: 0;
          box-shadow: none;
          min-height: 0;
          padding: 0;
          margin: 0;
        }

        @define-color bg    #${bg};
        @define-color fg    #${fg};
        @define-color focus #${focus};

        window#waybar {
          background: @bg;
          color: @fg;
          padding: 0;
          margin: 0;
        }

        #workspaces {
          background: transparent;
          padding: 0;
          margin: 0;
        }

        #workspaces button {
          background: @bg;
          color: @fg;
          padding: 0;
          margin: 0;
          min-height: 0;
        }

        #workspaces button.focused,
        #workspaces button:hover {
          background: @focus;
          color: @bg;
        }

        #network, #custom-bat, #disk, #memory, #clock {
          padding: 0;
          margin: 0;
        }
      '';
    };
  };
}
