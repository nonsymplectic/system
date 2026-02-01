{ config, lib, pkgs, ui, ... }:

let
  cfg = config.my.wm;

  stripHash = s: lib.removePrefix "#" s;

  bg = stripHash ui.colors.background;
  fg = stripHash ui.colors.foreground;
  focus = stripHash ui.colors.focus;

  s = ui.scale or 1.0;

  px = x: builtins.floor (x + 0.5);

  fontPx = px (ui.monoFont.size * s);
  heightPx = px (1.8 * fontPx);
  spacingPx = px (0.55 * fontPx);

  vPadPx = px (0.20 * fontPx);
  hPadPx = px (0.45 * fontPx);

  wsHPadPx = px (0.55 * fontPx);

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
  config = lib.mkIf (cfg.enable && cfg.bar.enable && cfg.bar.backend == "waybar") {
    my.wm.bar.command = "waybar";

    home.packages = [ pkgs.waybar ];

    xdg.configFile."waybar/config".text = builtins.toJSON {
      layer = "top";
      position = cfg.bar.position;

      height = heightPx;
      spacing = spacingPx;

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

      # /: 2.65/15.55GiB |
      disk = {
        interval = 90;
        path = "/";
        unit = "GiB";
        format = "/: {specific_used:0.2f}/{specific_total:0.2f}GiB |";
        tooltip = false;
      };

      # MEM: 2.65/15.55GiB |
      memory = {
        interval = 45;
        format = "MEM: {used:0.2f}/{total:0.2f}GiB |";
        tooltip = false;
      };

      # Sat 2026-01-31 22:30
      clock = {
        interval = 45;
        format = "{:%a %F %H:%M}";
        tooltip = false;
      };
    };

    xdg.configFile."waybar/style.css".text = ''
      * {
        font-family: "${ui.monoFont.family}";
        font-size: ${toString fontPx}px;
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
        padding: ${toString vPadPx}px ${toString hPadPx}px;
      }

      #workspaces {
        background: transparent;
      }

      #workspaces button {
        background: @bg;
        color: @fg;
        padding: 0 ${toString wsHPadPx}px;
        margin: 0;
        min-height: 0;
      }

      #workspaces button.focused {
        background: @focus;
        color: @bg;
      }

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
}
