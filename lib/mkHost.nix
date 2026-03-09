{ inputs }:
{ system
, modules ? [ ]
, baselineModule ? ({ ... }: { })
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit system;
  };

  catppuccin = inputs.catppuccin;

in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs pkgsUnstable catppuccin;
  };

  modules =
    [
      baselineModule
      inputs.catppuccin.nixosModules.catppuccin
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
    ]
    ++ modules;
}
