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
        <iframe src="https://giphy.com/embed/26ufdipQqU2lhNA4g" width="480" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe>
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
    virtualHosts."test.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        root = "/var/www/";
        extraConfig = ''
          include ${pkgs.nginx}/conf/uwsgi_params;
          uwsgi_modifier1 14;
          uwsgi_pass unix:${config.services.uwsgi.instance.vassals.php.socket};
        '';
      };
    };
  };

  services.uwsgi = {
    enable = true;
    user = "nginx";
    group = "nginx";
    instance = {
      type = "emperor";
      vassals = {
        php = {
          type = "normal";
          socket = "/run/uwsgi/php.sock";
          master = true;
          vacuum = true;
          processes = 4;
          cheaper = 1;
          php-sapi-name = "apache"; # performance tweak
          socket-modifier1 = 14;
          php-index = "index.php";
          php-set = [ "session.save_handler=files" "session.save_path=/var/www/sessions" ]; # fixes session issues with Nextcloud
          plugins = [ "php" ];
        };
      };
    };
    plugins = [ "php" ];
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
      LANDING_PAGE = explore
    '';
  };

  system.autoUpgrade.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}

