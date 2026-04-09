# Dev tools feature
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.dev-tools;

  devenvCmd = pkgs.writeShellScriptBin "dev-env" ''
    set -euo pipefail

    dir="$PWD"
    pids=()

    cleanup() {
      local pid
      for pid in "''${pids[@]}"; do
        kill "$pid" 2>/dev/null || true
      done
    }

    trap cleanup HUP INT TERM EXIT

    foot --title="nvim"    --working-directory="$dir" nvim . 2>/dev/null &
    pids+=("$!")

    foot --title="shell"   --working-directory="$dir" 2>/dev/null &
    pids+=("$!")

    foot --title="lazygit" --working-directory="$dir" lazygit 2>/dev/null &
    pids+=("$!")

    wait
  '';
in {
  options.features.dev-tools = {
    enable = lib.mkEnableOption "developer tools";

    uv = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable uv";
    };

    nix-ld = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable nix-ld for running non-Nix dynamic binaries";
    };

    lazygit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable lazygit";
    };

    dev-env = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable devenv command";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = lib.mkIf cfg.nix-ld true;

    home-manager.sharedModules = [
      {
        home.packages =
          (lib.optionals cfg.uv [pkgs.uv])
          ++ (lib.optionals cfg.lazygit [pkgs.lazygit])
          ++ (lib.optionals cfg.dev-env [devenvCmd]);
      }
    ];
  };
}
