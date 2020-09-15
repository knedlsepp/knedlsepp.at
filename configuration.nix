{ config, pkgs, ... }:
let
  domain-name = "knedlsepp.at";
in {
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  nix = {
    autoOptimiseStore = true;
    daemonNiceLevel = 5;
    daemonIONiceLevel = 5;
    extraOptions = ''
      auto-optimise-store = true
      min-free = ${toString (3 * 1024 * 1024 * 1024)}
      max-free = ${toString (6 * 1024 * 1024 * 1024)}
    '';
    buildMachines = [
      {
        hostName = "localhost";
        systems = [ "i686-linux" "x86_64-linux" ];
        maxJobs = 6;
        supportedFeatures = [ "kvm" "nixos-test" ];
      }
    ];
    gc = {
      automatic = true;
      dates = "14:09";
    };
    useSandbox = true;
  };
  nixpkgs.overlays = let
    workaroundBrokenGDAL = self: super: {
      hdf4 = super.hdf4.overrideAttrs(o: {
        doCheck = false;
      });
    };
  in [
    (import (fetchGit https://github.com/knedlsepp/nixpkgs-overlays.git))
  ];
  time.timeZone = "Europe/Vienna";

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.0.2u"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = super: let self = super.pkgs; in {
  };

  environment.systemPackages = with pkgs; [
    vim
    gitMinimal
    lsof
    htop
    duc
    fzf
  ];

  programs.vim.defaultEditor = true;

  programs.bash = {
    enableCompletion = true;
    shellAliases = {
      l = "ls -rltah";
    };
    loginShellInit = ''
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.bash"
      fi
    '';
  };

  security.acme.email = "josef.kemetmueller@gmail.com";
  security.acme.acceptTerms = true;
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
    virtualHosts."${domain-name}" = {
      serverAliases = [ "www.${domain-name}" ];
      enableACME = true;
      forceSSL = true;
      root = builtins.fetchGit {
        url = "https://github.com/knedlsepp/knedlsepp.at-landing-page.git";
        rev = "eee2a291a6e957672427082c4df8fdc67c9c35fa";
      };
    };
    virtualHosts."xn--qeiaa.${domain-name}" = { # ❤❤❤.${domain-name} - Punycoded
      serverAliases = [
        "xn--c6haa.${domain-name}"
        "xn--yr8haa.${domain-name}"
        "xn--0r8haa.${domain-name}"
        "xn--1r8haa.${domain-name}"
        "xn--2r8haa.${domain-name}"
        "xn--3r8haa.${domain-name}"
        "xn--4r8haa.${domain-name}"
        "xn--5r8haa.${domain-name}"
        "xn--6r8haa.${domain-name}"
        "xn--7r8haa.${domain-name}"
        "xn--8r8haa.${domain-name}"
        "xn--9r8haa.${domain-name}"
        "xn--g6haa.${domain-name}"
        "xn--r28haa.${domain-name}"
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
              <title>❤️❤️❤️.${domain-name}</title>
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
    virtualHosts."party.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      root = let
        site = pkgs.writeTextFile {
          name = "index.html";
          destination = "/share/www/index.html";
          text = ''
            <!DOCTYPE html>
            <html><head><meta charset=utf-8>
            <title>KnödelZ Sternstunden</title>
            <meta name="viewport" content="width=device-width">
            <style type="text/css">
                html, body {
                    height: 100%;
                    margin: 0px;
                    text-align: center;
                    vertical-align: middle;
                    font-size: 30pt;
                    background-color:#ff8c00;
                }
                .container {
                    height: 100%;
                    text-align: center;
                    vertical-align: middle;
                    font-size: 30pt;
                }
            </style>
            <script>
            window.addEventListener('load', function() {
            // sleep time expects milliseconds
            function sleep (time) {
              return new Promise((resolve) => setTimeout(resolve, time));
            }
                var waitingMessage = "<br>Einen Moment, wir berechnen deinen Party-Aszendenten.<br><br>Du wirst ...";
                var b = document.getElementById('b');
                var o = document.getElementById('o'),
                report = function(e) {
                    var textArray = [
                        'Dich heute mit deinen Dancemoves von der Partymasse abheben.',
                        'den 90s Dancefloor regieren.',
                        'mit einer Person mit gleichem Anfangsbuchstaben einen Schnaps trinken.',
                        'Einen Kichererbsen-Knödel vernaschen.',
                        'jetzt mit Christl einen Schnaps trinken.',
                        'eine Holzlaterne mitnehmen.',
                        'Dich heute Abend mit Herbert vorstellen.',
                        'einen Rugbyball verdrücken.',
                        'morgen von nichts mehr wissen.',
                        'über Evas Zimmer die Partyjacke des Abends finden.',
                        'jemanden zum Beer Pong herausfordern.',
                        'jemanden auf Deinen Schultern herumtragen.',
                        'morgen mit einem Toast an der Backe aufwachen.',
                        'beim Beer Pong gewinnen.',
                        'deine Unterhose verlieren.',
                        'eine Polonaise anzetteln.',
                        'den Enzianschnaps verfluchen.',
                        'deine Schuhe verlieren.',
                        'nicht alleine heimgehen<br>(zumindest mit am Rausch!).',
                        'eine Runde Looping Louie anzetteln.',
                        'dem Horoskop beweisen, dass Du noch nicht zu alt für einen Vollrausch bist',
                    ];
                    var randomNumber = Math.floor(Math.random()*textArray.length);


                    o.innerHTML = waitingMessage;
                    sleep(3000).then(() => {
                        var s = "...<br>" + textArray[randomNumber];
                        delayedInnerHTML(s);
                        //setTimeout(function() { delayedInnerHTML(s) }, 0);
                    });
                    sleep(7500).then(() => {
                        delayedInnerHTML("<br>???");
                        //setTimeout(function() { delayedInnerHTML("<br>???") }, 0);
                    });

                }

                /* Hack to work around new iOS8 behavior where innerHTML counts as a content change - previously, it was safe to use, see http://www.quirksmode.org/blog/archives/2014/02/the_ios_event_c.html */
                delayedInnerHTML = function(s) {
                    o.innerHTML = s;
                }

                /* and here we have it...the naive approach to handling touch */
                var clickEvent = ('ontouchstart' in window ? 'touchend' : 'click');
                b.addEventListener(clickEvent, report, false);

            }, false);
            </script>
            </head><body id="b" style="">
            <output class="container" id="o" ><br>???</output>
            </body></html>
          '';
        }; in
      "${site}/share/www/";
    };
    virtualHosts."hydra.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3001";
    };
    virtualHosts."uwsgi-example.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        extraConfig = ''
          uwsgi_pass unix://${config.services.uwsgi.instance.vassals.flask-helloworld.socket};
          include ${pkgs.nginx}/conf/uwsgi_params;
        '';
      };
    };
    virtualHosts."shell.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:4200";
    };
    virtualHosts."mattermost.${domain-name}" = {
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
    siteUrl = "https://mattermost.${domain-name}";
    extraConfig = {
      EmailSettings = {
        SendEmailNotifications = true; # TODO: Set up SMTP server
        EnablePreviewModeBanner = true;
      };
    };
  };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.${domain-name}";
    notificationSender = "hydra@${domain-name}";
    port = 3001;
    minimumDiskFree = 1; #GiB
    useSubstitutes = true;
    package = pkgs.hydra-unstable;
  };
  virtualisation.docker.enable = false;

  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-20.09";
  };
  networking.hostName = "knedlsepp-aws";
  networking.firewall.allowedTCPPorts = [ 80 443
   5900 5901 # VNC
  ];

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
    extraGroups = [ "docker" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}

