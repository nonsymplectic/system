{ lib, ... }:

{
  options.my.wm = {
    enable = (lib.mkEnableOption "window manager configuration") // {
      default = true;
      description = "Enable window manager configuration.";
    };

    backend = lib.mkOption {
      type = lib.types.enum [ "sway" ];
      default = "sway";
      description = "Window manager backend to configure.";
    };

    terminal = lib.mkOption {
      type = lib.types.enum [ "foot" ];
      default = "foot";
      description = "Terminal emulator used by keybindings and WM integration.";
    };

    launcher = lib.mkOption {
      type = lib.types.enum [ "wofi" ];
      default = "wofi";
      description = "Application launcher used by keybindings.";
    };

    bar = {
      enable = (lib.mkEnableOption "bar") // {
        default = true;
        description = "Enable bar/statusline configuration.";
      };

      backend = lib.mkOption {
        type = lib.types.enum [ "waybar" ];
        default = "waybar";
        description = "Bar implementation to configure.";
      };

      position = lib.mkOption {
        type = lib.types.enum [ "top" "bottom" ];
        default = "bottom";
        description = "Bar position on the screen.";
      };

      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Override bar launch command (null = managed by module).";
      };
    };

    keybindingOverrides = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Attribute set of keybinding overrides (WM-specific syntax in values).";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra raw configuration appended to the generated WM config.";
    };

    backendFlags = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      description = "Extra per-backend flags/arguments as attrset of string lists.";
    };
  };
}
