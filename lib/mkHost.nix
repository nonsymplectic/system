{ inputs }:
{ system
, modules ? [ ]
, baselineModule ? ({ ... }: { })
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = { inherit inputs; };

  modules =
    [
      baselineModule
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
    ]
    ++ modules;
}
