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
    virtualHosts."gogs.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3000";
    };
  };


  services.gogs = {
    appName = "Knedlgit";
    enable = true;
    rootUrl = "https://gogs.knedlsepp.at/";
    cookieSecure = true;
    extraConfig = ''
      [service]
      DISABLE_REGISTRATION = true
      DISABLE_SSH = true
    '';
  };

  system.autoUpgrade.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

