{ config, pkgs, ... }:
let
  knedlsepp_at = pkgs.writeTextFile {
    name = "index.html";
    destination = "/share/www/index.html";
    text = ''
      <!DOCTYPE html>
      <html lang="de">
      <head>
          <meta charset="utf-8">
          <title>knedlsepp.at</title>
      </head>
      <body id="home">
        <ul>
          <li><a href="https://gogs.knedlsepp.at">💾 - gogs.knedlsepp.at</a></li>
        </ul>
      </body>
      </html>
    '';
  };
in
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
      serverAliases = [ "www.knedlsepp.at" ];
      enableACME = true;
      forceSSL = true;
      root = "${knedlsepp_at}/share/www/";
    };
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
    extraConfig = ''
      [service]
      DISABLE_REGISTRATION = true
      [server]
      DISABLE_SSH = true
    '';
  };

  system.autoUpgrade.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

