{
  description = "Unified NixOS + Home Manager flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix/release-25.11";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    mkHost = import ./lib/mkHost.nix {inherit inputs;};

    # Flake-global baseline (nix tooling + stateVersion)
    baselineModule = {...}: {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      system.stateVersion = "25.11";
    };
  in {
    lib.mkHost = mkHost;

    nixosConfigurations = {
      home-pc = mkHost {
        system = "x86_64-linux";
        baselineModule = baselineModule;
        modules = [./hosts/home-pc];
      };

      laptop = mkHost {
        system = "x86_64-linux";
        baselineModule = baselineModule;
        modules = [./hosts/laptop];
      };
    };
  };
}
