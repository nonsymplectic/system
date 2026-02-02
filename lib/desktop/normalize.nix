{ lib }:

policy:
let
  # Convenience
  flagsFor = name: policy.extraFlags.${name} or [ ];

  # Render flags safely for a command string.
  renderFlags = flags:
    lib.concatStringsSep " " (map lib.escapeShellArg flags);

  mkCommand = base: flags:
    if flags == [ ] then base else "${base} ${renderFlags flags}";

  # Component-specific commands
  wmName = policy.wm;
  terminalName = policy.terminal;
  launcherName = policy.launcher;

  wmCommand =
    if wmName == "sway"
    then mkCommand "sway" (flagsFor "sway")
    else throw "normalizeDesktopPolicy: unsupported wm: ${wmName}";

  terminalCommand =
    if terminalName == "foot"
    then mkCommand "foot" (flagsFor "foot")
    else throw "normalizeDesktopPolicy: unsupported terminal: ${terminalName}";

  launcherCommand =
    if launcherName == "wofi"
    then mkCommand "wofi --show drun" (flagsFor "wofi")
    else throw "normalizeDesktopPolicy: unsupported launcher: ${launcherName}";

  barBackendName = policy.bar.backend;

  barBackendCommand =
    if barBackendName == "waybar"
    then mkCommand "waybar" (flagsFor "waybar")
    else throw "normalizeDesktopPolicy: unsupported bar backend: ${barBackendName}";

  # Wiring-only session env. Keep this intentionally small.
  wiringEnv =
    lib.mkMerge [
      {
        XDG_SESSION_TYPE = "wayland";
      }
      (lib.mkIf policy.enable {
        XDG_CURRENT_DESKTOP = wmName;
      })
    ];

  assertions = [
    {
      assertion = policy.enable -> (wmName != null);
      message = "desktop enabled but wm is null (should not be possible with enum).";
    }
    {
      assertion = (!policy.bar.enable) || (policy.bar.backend != null);
      message = "bar enabled but bar.backend is null (should not be possible with enum).";
    }
  ];
in
{
  enable = policy.enable;

  wm = {
    name = wmName;
    flags = flagsFor wmName;
    command = wmCommand;
  };

  terminal = {
    name = terminalName;
    flags = flagsFor terminalName;
    command = terminalCommand;
  };

  launcher = {
    name = launcherName;
    flags = flagsFor launcherName;
    command = launcherCommand;
  };

  bar = {
    enable = policy.bar.enable;
    position = policy.bar.position;
    backend = {
      name = barBackendName;
      flags = flagsFor barBackendName;
      command = barBackendCommand;
    };
  };

  env = wiringEnv;

  inherit assertions;
}
