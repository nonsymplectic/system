{ lib
, pkgs
, ui
, desktop
, ...
}:

let
  enabled = desktop.enable && desktop.terminal.name == "foot";

  stripHash = s: lib.removePrefix "#" s;

  p = i: stripHash (builtins.elemAt ui.terminal.palette i);
in
{
  /*
    Foot (Home Manager plugin)

    Responsibilities:
      - Self-gate on normalized desktop payload (`desktop.*`).
      - Enable + configure foot via Home Manager (programs.foot.*).
      - Colors and font derive from immutable UI tokens (`ui.*`).
  */

  config = lib.mkIf enabled {
    programs.foot = {
      enable = true;

      settings = {
        main = {
          font = "${ui.monoFont.family}:size=${toString ui.monoFont.size}";
        };

        cursor = {
          blink = true;
        };
      };
    };
  };
}
