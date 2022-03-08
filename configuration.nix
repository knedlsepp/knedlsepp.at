{ config, pkgs, ... }:
let
  domain-name = "knedlsepp.at";
in {
  imports = [ ];
  ec2.hvm = true;

  nix = {
    package = pkgs.nix_2_4;
    autoOptimiseStore = true;
    extraOptions = ''
      auto-optimise-store = true
      min-free = ${toString (3 * 1024 * 1024 * 1024)}
      max-free = ${toString (6 * 1024 * 1024 * 1024)}
      experimental-features = nix-command flakes
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
  nixpkgs.overlays = [ ];
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
    virtualHosts."josefundlena.at" = {
      serverAliases = [ "www.josefundlena.at" ];
      enableACME = true;
      forceSSL = true;
      root = builtins.fetchGit {
        url = "git@github.com:knedlsepp/save-the-date.git";
        ref = "main";
        rev = "2115be59a1770bf585ad331361167c4ed0cbe67e";
      };
    };
    virtualHosts."${domain-name}" = {
      serverAliases = [ "www.${domain-name}" ];
      enableACME = true;
      forceSSL = true;
      root = builtins.fetchGit {
        url = "https://github.com/knedlsepp/knedlsepp.at-landing-page.git";
        rev = "c4c14fdf5acdd71fdb0bd6369da282ec685af407";
      };
    };
    virtualHosts."lalensch.at" = {
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
              <title>LaLensch</title>
              <style>
              h1 {
                  display: block;
                  font-size: 8em;
                  font-weight: bold;
              }
              </style>
            </head>
            <body>
            <body><br><br><h1><center><div>LaLensch.at coming soon 🛠️</div></center></h1></body>
            </html>
          '';
        }; in
      "${site}/share/www/";
    };
    virtualHosts."hydra.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:3001";
    };
    virtualHosts."shell.${domain-name}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:4200";
    };
  };

  services.shellinabox = {
    enable = true;
    extraOptions = [ "--localhost-only" ]; # Nginx makes sure it's https
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

  users.users."sepp".openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILzIWsoe/+qZ/bjEBf64bq0MOkikSnTq/95+b2pbgu4jAAAABHNzaDo= ssh:"
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

