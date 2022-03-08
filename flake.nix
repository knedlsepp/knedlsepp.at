{
  description = "knedlsepp.at";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";

  outputs = { self, nixpkgs }:
  {
    nixosConfigurations = {
      knedlsepp-aws = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          {
            nix.registry.self.flake = self;
          }
        ];
      };
    };
  };
}


