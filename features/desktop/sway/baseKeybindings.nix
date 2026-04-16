{
  config,
  pkgs,
}: {
  # Launch / session
  "Mod4+Return" = "exec foot";
  "Mod4+d" = "exec fuzzel";
  "Mod4+Shift+f" = "exec ${config.features.browsers.command}";
  "Mod4+Shift+q" = "kill";
  "Mod4+Shift+r" = "reload";
  "Mod4+Shift+e" = "exec swaymsg exit";
  "Mod4+Shift+p" = "exec ${pkgs.swaylock-effects}/bin/swaylock";

  # Focus movement (vim + arrows)
  "Mod4+h" = "focus left";
  "Mod4+j" = "focus down";
  "Mod4+k" = "focus up";
  "Mod4+l" = "focus right";
  "Mod4+Left" = "focus left";
  "Mod4+Down" = "focus down";
  "Mod4+Up" = "focus up";
  "Mod4+Right" = "focus right";

  # Focus parent
  "Mod4+a" = "focus parent";

  # Container movement
  "Mod4+Shift+h" = "move left";
  "Mod4+Shift+j" = "move down";
  "Mod4+Shift+k" = "move up";
  "Mod4+Shift+l" = "move right";
  "Mod4+Shift+Left" = "move left";
  "Mod4+Shift+Down" = "move down";
  "Mod4+Shift+Up" = "move up";
  "Mod4+Shift+Right" = "move right";

  # Layout
  "Mod4+s" = "layout stacking";
  "Mod4+w" = "layout tabbed";
  "Mod4+e" = "layout toggle split";
  "Mod4+b" = "splith";
  "Mod4+v" = "splitv";

  # Fullscreen / floating
  "Mod4+f" = "fullscreen toggle";
  "Mod4+Shift+space" = "floating toggle";
  "Mod4+space" = "focus mode_toggle";

  # Workspaces
  "Mod4+1" = "workspace number 1";
  "Mod4+2" = "workspace number 2";
  "Mod4+3" = "workspace number 3";
  "Mod4+4" = "workspace number 4";
  "Mod4+5" = "workspace number 5";
  "Mod4+6" = "workspace number 6";
  "Mod4+7" = "workspace number 7";
  "Mod4+8" = "workspace number 8";
  "Mod4+9" = "workspace number 9";
  "Mod4+0" = "workspace number 10";

  "Mod4+Shift+1" = "move container to workspace number 1";
  "Mod4+Shift+2" = "move container to workspace number 2";
  "Mod4+Shift+3" = "move container to workspace number 3";
  "Mod4+Shift+4" = "move container to workspace number 4";
  "Mod4+Shift+5" = "move container to workspace number 5";
  "Mod4+Shift+6" = "move container to workspace number 6";
  "Mod4+Shift+7" = "move container to workspace number 7";
  "Mod4+Shift+8" = "move container to workspace number 8";
  "Mod4+Shift+9" = "move container to workspace number 9";
  "Mod4+Shift+0" = "move container to workspace number 10";

  "Mod4+Tab" = "workspace back_and_forth";

  # Resize mode
  "Mod4+r" = "mode resize";

  # Laptop Volume controls
  "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -t 2000 -h string:x-canonical-private-synchronous:sys-notify -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') 'Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if ($3 == \"[MUTED]\") print \"muted\"; else print int($2*100) \"%\"}')\"";
  "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -t 2000 -h string:x-canonical-private-synchronous:sys-notify -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') 'Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if ($3 == \"[MUTED]\") print \"muted\"; else print int($2*100) \"%\"}')\"";
  "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -t 2000 -h string:x-canonical-private-synchronous:sys-notify -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}') 'Volume' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if ($3 == \"[MUTED]\") print \"muted\"; else print int($2*100) \"%\"}')\"";
  "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify-send -t 2000 -h string:x-canonical-private-synchronous:mic-notify -h int:value:$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print int($2*100)}') 'Microphone' \"$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{if ($3 == \"[MUTED]\") print \"muted\"; else print int($2*100) \"%\"}')\"";
}
