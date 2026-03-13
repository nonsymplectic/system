{
  lib,
  pkgs,
  ui,
  desktop,
  ...
}:

let
  /*
    Sway (Home Manager plugin)

    Responsibilities:
      - Self-gate on normalized desktop payload (`desktop.*`).
      - Configure Sway via Home Manager (wayland.windowManager.sway).
      - Interpret desktop selections (terminal/launcher/bar) into Sway config.
  */

  enabled = desktop.enable && desktop.wm.name == "sway";

  menuCmd = desktop.launcher.command;

  hex = c: lib.removePrefix "#" c;
  alpha = a: c: "${hex c}${a}";

  swaylockSettings = {
    indicator = true;
    clock = true;

    inside-color = alpha "cc" ui.colors.background;
    inside-clear-color = alpha "cc" ui.colors.muted;
    inside-caps-lock-color = alpha "cc" ui.colors.muted;
    inside-ver-color = alpha "cc" ui.colors.focus;
    inside-wrong-color = alpha "cc" ui.colors.error;

    ring-color = alpha "ff" ui.colors.muted;
    ring-clear-color = alpha "ff" ui.colors.focus;
    ring-caps-lock-color = alpha "ff" ui.colors.focus;
    ring-ver-color = alpha "ff" ui.colors.focus;
    ring-wrong-color = alpha "ff" ui.colors.error;

    line-uses-ring = true;

    separator-color = alpha "00" ui.colors.background;
    key-hl-color = alpha "ff" ui.colors.focus;

    text-color = alpha "ff" ui.colors.foreground;
    text-clear-color = alpha "ff" ui.colors.foreground;
    text-caps-lock-color = alpha "ff" ui.colors.foreground;
    text-ver-color = alpha "ff" ui.colors.foreground;
    text-wrong-color = alpha "ff" ui.colors.foreground;

    layout-bg-color = alpha "cc" ui.colors.background;
    layout-border-color = alpha "ff" ui.colors.muted;
    layout-text-color = alpha "ff" ui.colors.foreground;

    screenshots = true;
    show-keyboard-layout = true;
    show-failed-attempts = true;
    effect-pixelate = 16;
  };

  lockCmd = "${pkgs.swaylock-effects}/bin/swaylock";

  barCmd = if desktop.bar.enable then desktop.bar.backend.command else null;

  barBin = if barCmd == null then null else lib.head (lib.splitString " " barCmd);

  barAutostart = lib.optionalString (barCmd != null) ''
    exec sh -lc '${pkgs.procps}/bin/pgrep -x ${lib.escapeShellArg barBin} >/dev/null || exec ${barCmd}'
  '';

  disableFloating = ''
    for_window [floating] floating disable
  '';

  wallpaperDir = ../../../../options/wallpapers;
  wallpaperPath = wallpaperDir + ("/" + "wall.png");
  wallpaperSetting = ''
    output * bg ${wallpaperPath} fill
  '';

  clientColors = {
    focused = {
      border = ui.colors.background;
      indicator = ui.colors.background;
      childBorder = ui.colors.focus;
      background = ui.colors.background;
      text = ui.colors.focus;
    };

    focusedInactive = {
      border = ui.colors.background;
      childBorder = ui.colors.background;
      indicator = ui.colors.muted;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };

    unfocused = {
      border = ui.colors.background;
      childBorder = ui.colors.background;
      indicator = ui.colors.muted;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };

    urgent = {
      border = ui.colors.error;
      indicator = ui.colors.error;
      childBorder = ui.colors.error;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };

    placeholder = {
      border = ui.colors.muted;
      indicator = ui.colors.muted;
      childBorder = ui.colors.muted;
      background = ui.colors.background;
      text = ui.colors.foreground;
    };
  };

  baseKeybindings = {
    # Launch / session
    "Mod4+Return" = "exec ${desktop.terminal.command}";
    "Mod4+d" = "exec ${menuCmd}";
    "Mod4+Shift+q" = "kill";
    "Mod4+Shift+r" = "reload";
    "Mod4+Shift+e" = "exec swaymsg exit";
    "Mod4+Shift+p" = "exec ${lockCmd}";

    # Focus movement (vim + arrows)
    "Mod4+h" = "focus left";
    "Mod4+j" = "focus down";
    "Mod4+k" = "focus up";
    "Mod4+l" = "focus right";
    "Mod4+Left" = "focus left";
    "Mod4+Down" = "focus down";
    "Mod4+Up" = "focus up";
    "Mod4+Right" = "focus right";

    # Focus parent (escape nested containers)
    "Mod4+a" = "focus parent";

    # Container movement (vim + arrows)
    "Mod4+Shift+h" = "move left";
    "Mod4+Shift+j" = "move down";
    "Mod4+Shift+k" = "move up";
    "Mod4+Shift+l" = "move right";
    "Mod4+Shift+Left" = "move left";
    "Mod4+Shift+Down" = "move down";
    "Mod4+Shift+Up" = "move up";
    "Mod4+Shift+Right" = "move right";

    # Layout: tabbed / stacking / splits (Sway defaults)
    "Mod4+s" = "layout stacking";
    "Mod4+w" = "layout tabbed";
    "Mod4+e" = "layout toggle split";
    "Mod4+b" = "splith";
    "Mod4+v" = "splitv";

    # Fullscreen / floating
    "Mod4+f" = "fullscreen toggle";
    "Mod4+Shift+space" = "floating toggle";
    "Mod4+space" = "focus mode_toggle";

    # Workspaces (1-10) + move container to workspace
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

    # Workspace back-and-forth
    "Mod4+Tab" = "workspace back_and_forth";

    # Resize mode
    "Mod4+r" = "mode resize";
  };

  keybindings = baseKeybindings;
in
{
  config = lib.mkIf enabled {
    # Sway comes with mako for notifications per default
    services.mako = {
      enable = true;

      settings = {
        background-color = ui.colors.background;
        text-color = ui.colors.foreground;
        border-color = ui.colors.muted;
        progress-color = "over ${ui.colors.focus}";
      };

      extraConfig = ''
        [urgency=high]
        border-color=${ui.colors.error}

        [urgency=normal]
        border-color=${ui.colors.focus}
      '';
    };

    # Swaylock for a lockscreen
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = swaylockSettings;
    };

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;

      # Sway-specific extra flags come from normalization.
      extraOptions = desktop.wm.flags;

      config = lib.mkMerge [
        {
          defaultWorkspace = "workspace number 1";
          workspaceLayout = "tabbed";

          # terminal/menu are Sway-native strings.
          terminal = desktop.terminal.command;
          menu = menuCmd;

          fonts = {
            names = [ ui.font.family ];
            size = builtins.toString ui.font.size;
          };

          colors = clientColors;

          keybindings = keybindings;
        }

        # Disable built-in swaybar when using an external bar.
        (lib.mkIf desktop.bar.enable { bars = [ ]; })
      ];

      extraConfig = disableFloating + barAutostart + wallpaperSetting;
    };
  };
}
