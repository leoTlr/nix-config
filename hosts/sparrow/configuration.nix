{ config, ... }:
{
  # VM on relaxo
  profiles = {
    base.stateVersion = "25.05";
    server.enable = true;
  };

  networking.nameservers = [ "192.168.1.50" ];

  systemd.network.networks."10-lan" = {
    enable = true;
    matchConfig.Name = "enp5s0";
    address = [ "192.168.1.41/24" ];
    routes = [ { Gateway = "192.168.1.1"; } ];
  };

  sops.secrets = {
    "alloy/user" = {};
    "alloy/apikey" = {};
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

  syslib = {

    appproxy = {
      tls = {
        certFile = config.sops.secrets."traefik/tls/cert".path;
        certKeyFile = config.sops.secrets."traefik/tls/certKey".path;
      };
      auth = {
        jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        adminPassword = config.sops.placeholder."authelia/adminPassword";
      };
    };

    arrstack = {
      enable = true;
      domain = "arr.home.arpa";
      waitOnMountUnits = [ "mnt-relaxo-media.mount" ];
      radarr = {
        enable = true;
        libraryDir = "/mnt/relaxo/media/movies";
        downloadDir = config.syslib.arrstack.sabnzbd.outDir;
        apiKey = config.sops.placeholder."radarr/apikey";
      };
      sonarr = {
        enable = true;
        libraryDir = "/mnt/relaxo/media/series";
        downloadDir = config.syslib.arrstack.sabnzbd.outDir;
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

    nfsmounts = {
      enable = true;
      mounts = ["relaxo.home.arpa:/mnt/tank/media:/mnt/relaxo/media"];
    };

  };

}
