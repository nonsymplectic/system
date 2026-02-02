{ config, lib, desktopPolicy, uiPolicy, ... }:

let
# desktop config needs some normalization
normalize = import ../../../lib/desktop/normalize.nix { inherit lib; };
desktop = normalize desktopPolicy;

# ui doesn't
in
{
  # Make `desktop`,'ui' available to every module imported after this interface.
  _module.args.desktop = desktop;
  _module.args.ui = uiPolicy;

  # Enforce invariants centrally (evaluation-time failure).
  assertions = desktop.assertions;

  # Wiring-only env can be applied globally from the interface.
  home.sessionVariables = desktop.env;

  # Import plugins unconditionally (they self-gate using `desktop`).
  imports = [
    ./wms/sway.nix
    ./bars/waybar.nix
    ./launchers/wofi.nix
    ./terminals/foot.nix
  ];
}
