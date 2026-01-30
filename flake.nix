{
  description = "Unified NixOS + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ... }:
  let
    mkHost = import ./lib/mkHost.nix { inherit inputs; };
  in
  {
    lib.mkHost = mkHost;

    nixosConfigurations = {
      laptop = mkHost {
        hostname = "nixos";
        system = "x86_64-linux";
        modules = [ ./hosts/laptop ];
      };

      home-pc = mkHost {
        hostname = "nixos";
        system = "x86_64-linux";
        modules = [ ./hosts/home-pc ];
      };
    };
  };
}
