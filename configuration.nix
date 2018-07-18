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
    extraOptions = ''
      auto-optimise-store = true
    '';
  };
  nixpkgs.overlays = [
    (import (fetchGit https://github.com/knedlsepp/nixpkgs-overlays.git))
  ];
  time.timeZone = "Europe/Vienna";

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
        rev = "6bb09bcca1bd39344d4e568c70b2ad31fd29f1bf";
      };
    };
    virtualHosts."30.jahre.knedlsepp.at" = let
      _30_jahre = pkgs.writeTextFile {
        name = "index.html";
        destination = "/share/www/index.html";
        text = ''
          <!DOCTYPE html>
          <html lang="de">
          <head>
              <meta charset="utf-8">
              <title>knedlsepp.at</title>
              <style>
                body {background-color: powderblue;}
                h1   {color: blue;}
                p    {color: red;}
                @keyframes fontbulger {
                  0% {
                    font-size: 70px;
                  }
                  20% {
                    font-size: 110px;
                  }
                  50% {
                    font-size: 130px;
                  }
                  70% {
                    font-size: 80px;
                  }
                  100% {
                    font-size: 70px;
                  }
                }

                #box {
                   animation: fontbulger 1s infinite;
                }
              </style>
          </head>
          <body id="home">
            <ul>
              <center>
              <iframe src="https://giphy.com/embed/W8krmZSDxPIfm" width="600" height="353" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/party-night-weekend-W8krmZSDxPIfm"></a></p>
            </ul>
          <span id=box><center>Feiert<br></center></span>
          <center>mit mir<br></center>
          <span id=box><center>30<br></center></span>
          <center>Jahre<br></center>
          <span id=box><center>Knedlsepp<br></center></span>
          <center>
          <iframe src="https://giphy.com/embed/DlGaTfcMeDmz6" width="600" height="343" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/dance-airplane-boogie-DlGaTfcMeDmz6"></a></p>
          </center>
          </body>
          </html>
        '';
      };
    in
    {
      serverAliases = [ "www.30.jahre.knedlsepp.at" ];
      enableACME = true;
      forceSSL = true;
      root = "${_30_jahre}/share/www/";
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
    extraConfig = {
      EmailSettings = {
        SendEmailNotifications = true; # TODO: Set up SMTP server
        EnablePreviewModeBanner = false;
      };
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
  networking.hostName = "knedlsepp-aws";
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

