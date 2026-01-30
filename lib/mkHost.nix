{ inputs }:
{ hostname
, system
, modules ? [ ]
}:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs;
  };

  modules =
    [
      ({ ... }: {
        networking.hostName = hostname;

        nixpkgs.hostPlatform = system;
        nixpkgs.config.allowUnfree = true;
      })

      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
    ]
    ++ modules;
}
