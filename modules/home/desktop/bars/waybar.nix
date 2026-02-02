{ lib, pkgs, ui, desktop, ... }:

let
  enabled =
    desktop.enable
    && desktop.bar.enable
    && desktop.bar.backend.name == "waybar";

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
  /*
    Waybar (Home Manager plugin)

    Responsibilities:
      - Self-gate on normalized desktop payload (`desktop.*`).
      - Enable + configure Waybar via Home Manager.
      - Style derives from immutable UI tokens (`ui.*`).
  */

  config = lib.mkIf enabled {
    programs.waybar = {
      enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = desktop.bar.position;

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
          font-family: "${ui.monoFont.family}";
          font-size: ${toString ui.monoFont.sizePx}px;
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
