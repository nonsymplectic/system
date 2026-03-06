{ inputs }:
{ system
, modules ? [ ]
, baselineModule ? ({ ... }: { })
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit system;
  };
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs pkgsUnstable;
  };

  modules =
    [
      baselineModule
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
    ]
    ++ modules;
}
