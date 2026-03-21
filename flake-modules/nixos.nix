# NixOS configurations using flake-parts
# Defines nixosConfigurations for all hosts
{inputs, self, ...}: {
  flake.nixosConfigurations = {
    home-pc = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
        };
        catppuccin = inputs.catppuccin;
      };

      modules = [
        ./baseline.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
        (self + "/hosts/home-pc")
      ];
    };

    laptop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
        };
        catppuccin = inputs.catppuccin;
      };

      modules = [
        ./baseline.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
        (self + "/hosts/laptop")
      ];
    };
  };
}
