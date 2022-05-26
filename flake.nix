{
  description = "knedlsepp.at";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
  inputs.save-the-date = {
    url = "git+ssh://git@github.com/knedlsepp/save-the-date.git?ref=main";
    flake = false;
  };

  outputs = { self, nixpkgs, save-the-date }:
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
          {
            services.nginx.virtualHosts."josefundlena.at" = {
              root = save-the-date;
            };
          }
        ];
      };
    };
  };
}


