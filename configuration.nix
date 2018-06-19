{ config, pkgs, ... }:
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    gc = {
      automatic = true;
      dates = "14:09";
    };
    useSandbox = true;
  };
  nixpkgs.overlays = [
    (import (fetchGit https://github.com/knedlsepp/nixpkgs-overlays.git))
  ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    gitMinimal
    lsof
    htop
    duc
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
      root = builtins.fetchGit {
        url = "https://github.com/knedlsepp/knedlsepp.at-landing-page.git";
        rev = "ac928df94100b0aea04f772ebb535c90829d54c6";
      };
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

  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-18.03";
  };
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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}

