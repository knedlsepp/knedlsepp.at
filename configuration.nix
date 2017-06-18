{ config, pkgs, ... }:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;
  
  environment.systemPackages = with pkgs; [
    vim
    gitAndTools.gitFull
    lsof
    htop
  ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      root = "${pkgs.valgrind.doc}/share/doc/valgrind/html";
    };
  };
}
