{
  description = "knedlsepp.at";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.05";

  outputs = { self, nixpkgs }:
  {
    nixosConfigurations = {
      knedlsepp-aws = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
          {
            nix.registry.self.flake = self;
          }
        ];
      };
    };
  };
}


