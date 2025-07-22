{ pkgs, config, userConfig, ... }:
let
  # VM on relaxo
  hostName = "sparrow";
  ip = "192.168.1.41";
in
{

  system.stateVersion = "25.05";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.enableAllTerminfo = true;

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
    nameservers = [ "192.168.1.50" ];
  };

  systemd.network.networks."10-lan" = {
    enable = true;
    matchConfig.Name = "enp5s0";
    address = [
      "${ip}/24"
    ];
    routes = [
      { Gateway = "192.168.1.1"; }
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      "traefik/tls/cert" = { owner = "traefik"; };
      "traefik/tls/certKey" = { owner = "traefik"; };
      "authelia/jwtSecret" = { owner = "authelia-main"; };
      "authelia/storageEncryptionKey" = { owner = "authelia-main"; };
      "authelia/adminPassword" = { owner = "authelia-main"; };
      "radarr/apikey" = {};
      "sonarr/apikey" = {};
      "prowlarr/apikey" = {};
      "sabnzbd/apikey" = {};
      "sabnzbd/nzbkey" = {};
      "sabnzbd/servers/A/host" = {};
      "sabnzbd/servers/A/port" = {};
      "sabnzbd/servers/A/connections" = {};
      "sabnzbd/servers/A/username" = {};
      "sabnzbd/servers/A/password" = {};
      "sabnzbd/servers/B/host" = {};
      "sabnzbd/servers/B/port" = {};
      "sabnzbd/servers/B/connections" = {};
      "sabnzbd/servers/B/username" = {};
      "sabnzbd/servers/B/password" = {};
    };
  };

  sops.gnupg = {
    home = "/root/.gnupg";
    sshKeyPaths = [];
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
  };

  syslib = {

    nix = {
      enable = true;
      remoteManaged = true;
    };

    users = {
      mutable = true;
      mainUser = {
        name = userConfig.userName;
        shell = pkgs.fish;
      };
    };

    sshd = {
      enable = true;
      authorizedKeys.${userConfig.userName} =
        [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi" ];
    };

    localization = {
      enable = true;
      inherit (userConfig.localization) timezone locale keymap;
    };

    nfsmounts = {
      enable = true;
      mounts = ["relaxo.home.arpa:/mnt/tank/media:/mnt/relaxo/media"];
    };

    arrstack = {
      enable = true;
      proxy = {
        certFile = config.sops.secrets."traefik/tls/cert".path;
        certKeyFile = config.sops.secrets."traefik/tls/certKey".path;
      };
      auth = {
        jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        adminPassword = config.sops.placeholder."authelia/adminPassword";
      };
      radarr = {
        enable = true;
        libraryDir = "/mnt/relaxo/media/moviesTEST";
        apiKey = config.sops.placeholder."radarr/apikey";
      };
      sonarr = {
        enable = true;
        libraryDir = "/mnt/relaxo/media/seriesTEST";
        apiKey = config.sops.placeholder."sonarr/apikey";
      };
      prowlarr = {
        enable = true;
        apiKey = config.sops.placeholder."prowlarr/apikey";
      };
      recyclarr = {
        enable = true;
        apiKeyPaths = {
          radarr = config.sops.secrets."radarr/apikey".path;
          sonarr = config.sops.secrets."sonarr/apikey".path;
        };
      };
      sabnzbd = {
        enable = true;
        outDir = "/mnt/relaxo/media/usenet";
        apiKey = config.sops.placeholder."sabnzbd/apikey";
        nzbKey = config.sops.placeholder."sabnzbd/nzbkey";
        usenetProviders = [
          {
            host = config.sops.placeholder."sabnzbd/servers/A/host";
            port = config.sops.placeholder."sabnzbd/servers/A/port";
            connections = config.sops.placeholder."sabnzbd/servers/A/connections";
            username = config.sops.placeholder."sabnzbd/servers/A/username";
            password = config.sops.placeholder."sabnzbd/servers/A/password";
            priority = 0;
          }
          {
            host = config.sops.placeholder."sabnzbd/servers/B/host";
            port = config.sops.placeholder."sabnzbd/servers/B/port";
            connections = config.sops.placeholder."sabnzbd/servers/B/connections";
            username = config.sops.placeholder."sabnzbd/servers/B/username";
            password = config.sops.placeholder."sabnzbd/servers/B/password";
            priority = 90;
          }
        ];
      };
    };

  };

  environment.systemPackages = with pkgs; [
    vim
    git
    dig
    lsof
    dysk
    gdu
  ];

  programs.fish.enable = true;

}
