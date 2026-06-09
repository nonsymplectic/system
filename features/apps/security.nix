# Security applications feature
# Home Manager only - password managers and security tools
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.security;
in {
  options.features.security = {
    enable = lib.mkEnableOption "Security applications";

    keepassxc = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable KeePassXC password manager";
    };
    gnupg = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GnuPG OpenPGP";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      ({
        lib,
        pkgs,
        ...
      }: {
        home.packages =
          (lib.optionals cfg.keepassxc [pkgs.keepassxc])
          ++ (lib.optionals cfg.gnupg [pkgs.gnupg]);

        services.gpg-agent = lib.mkIf cfg.gnupg {
          enable = true;
          pinentry.package = pkgs.pinentry-curses;
        };

        home.activation.importGpgKey = lib.mkIf cfg.gnupg (
          lib.hm.dag.entryAfter ["writeBoundary"] ''
            if [ -r /run/agenix/gpg_private_key ]; then
              $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpg --batch --import /run/agenix/gpg_private_key || true
            fi
          ''
        );
      })
    ];
  };
}
