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
      <body id="home" bgcolor="#000000" link="#eeeeee" vlink="#dddddd" alink="#cccccc" text="#ffffff">
        <center>
        <iframe src="https://giphy.com/embed/26ufdipQqU2lhNA4g" width="480" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe>
        <br>
        <a href="https://gogs.knedlsepp.at">💾 - gogs.knedlsepp.at</a><br><br>
        <a href="https://hydra.knedlsepp.at">🤖 - hydra.knedlsepp.at</a><br><br>
        <a href="https://shell.knedlsepp.at">🐚 - shell.knedlsepp.at</a><br><br>
        <a href="https://mattermost.knedlsepp.at">💬 - mattermost.knedlsepp.at</a><br><br>
        <a href="https://uwsgi-example.knedlsepp.at">🐍 - uwsgi-example.knedlsepp.at</a><br><br>
        </center>
        <center>
          <footer>
            <small>
            Impressum:
            <address>
            Josef Kemetmüller<br>
            Johann-Strauß-Gasse 4-6/2/8, 1040 Wien
            </address>
            </small>
          </footer>
        </center>
      </body>
      </html>
    '';
  };
in
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    gc = {
      automatic = true;
      dates = "14:09";
    };
    useSandbox = true;
    nixPath = [ "nixpkgs=https://nixos.org/channels/nixos-17.09/nixexprs.tar.xz"
                "nixos-config=/etc/nixos/configuration.nix"
                "knedlsepp-overlays=https://github.com/knedlsepp/nixpkgs-overlays/archive/master.tar.gz"
    ];
  };
  nixpkgs.overlays = [ (import <knedlsepp-overlays>) ]; # Be aware that we need a nix-collect-garbage to fetch the most current version
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    gitMinimal
    lsof
    htop
  ];

  programs.vim.defaultEditor = true;

  security.hideProcessInformation = true;

  services.openssh.forwardX11 = true;

  services.journald.extraConfig = ''
    SystemMaxUse=300M
  '';

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
    virtualHosts."xn--qeiaa.knedlsepp.at" = { # ❤❤❤.knedlsepp.at - Punycoded
      serverAliases = [
        "xn--c6haa.knedlsepp.at"
        "xn--yr8haa.knedlsepp.at"
        "xn--0r8haa.knedlsepp.at"
        "xn--1r8haa.knedlsepp.at"
        "xn--2r8haa.knedlsepp.at"
        "xn--3r8haa.knedlsepp.at"
        "xn--4r8haa.knedlsepp.at"
        "xn--5r8haa.knedlsepp.at"
        "xn--6r8haa.knedlsepp.at"
        "xn--7r8haa.knedlsepp.at"
        "xn--8r8haa.knedlsepp.at"
        "xn--9r8haa.knedlsepp.at"
        "xn--g6haa.knedlsepp.at"
        "xn--r28haa.knedlsepp.at"
      ];
      enableACME = true;
      forceSSL = true;
      root = let
        site = pkgs.writeTextFile {
          name = "index.html";
          destination = "/share/www/index.html";
          text = ''
            <!DOCTYPE html>
            <html lang="de">
            <head>
              <meta charset="utf-8">
              <title>❤️❤️❤️.knedlsepp.at</title>
              <style>
              h1 {
                  display: block;
                  font-size: 8em;
                  font-weight: bold;
              }
              </style>
            </head>
            <body>
            <body><br><br><h1><center><div>I ❤️ 🐰</div></center></h1></body>
            </html>
          '';
        }; in
      "${site}/share/www/";
    };
    virtualHosts."gogs.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3000";
    };
    virtualHosts."hydra.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3001";
    };
    virtualHosts."uwsgi-example.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        extraConfig = ''
          uwsgi_pass unix://${config.services.uwsgi.instance.vassals.flask-helloworld.socket};
          include ${pkgs.nginx}/conf/uwsgi_params;
        '';
      };
    };
    virtualHosts."shell.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:4200";
    };
    virtualHosts."mattermost.knedlsepp.at" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8065";
        proxyWebsockets = true;
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
        flask-helloworld = {
          type = "normal";
          pythonPackages = self: with self; [ flask-helloworld ];
          socket = "${config.services.uwsgi.runDir}/flask-helloworld.sock";
          wsgi-file = "${pkgs.pythonPackages.flask-helloworld}/${pkgs.python.sitePackages}/helloworld/share/flask-helloworld.wsgi";
        };
      };
    };
    plugins = [ "python2" ];
  };

  services.shellinabox = {
    enable = true;
    extraOptions = [ "--localhost-only" ]; # Nginx makes sure it's https
  };

  services.mattermost = {
    enable = true;
    siteUrl = "https://mattermost.knedlsepp.at";
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

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.knedlsepp.at";
    notificationSender = "hydra@knedlsepp.at";
    port = 3001;
    minimumDiskFree = 1; #GiB
    useSubstitutes = true;
  };
  nix.buildMachines = [
    {
      hostName = "localhost";
      systems = [ "i686-linux" "x86_64-linux" ];
      maxJobs = 6;
      supportedFeatures = [ "kvm" "nixos-test" ];
    }
  ];

  system.autoUpgrade.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 2048;
    }
  ];

  users.extraUsers.sepp = {
    isNormalUser = true;
    description = "Josef Knedlmüller";
    initialPassword = "foo";
  };
}

