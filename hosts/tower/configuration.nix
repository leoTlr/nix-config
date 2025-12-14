{ pkgs, config, userConfig, cfglib, lib, ... }:
{

  profiles = {
    base.stateVersion = "25.11";
    server.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [ "192.168.1.50" ];
  };

  sops.secrets = {
    "alloy/user" = {};
    "alloy/apikey" = {};
    "traefik/tls/cert" = { owner = "traefik"; };
    "traefik/tls/certKey" = { owner = "traefik"; };
    "authelia/jwtSecret" = { owner = "authelia-main"; };
    "authelia/storageEncryptionKey" = { owner = "authelia-main"; };
    "authelia/adminPassword" = { owner = "authelia-main"; };
    "location/latitude" = { owner = userConfig.userName; sopsFile = cfglib.paths.userSecretsFile userConfig.userName; };
    "location/longitude" = { owner = userConfig.userName; sopsFile = cfglib.paths.userSecretsFile userConfig.userName; };
  };

  syslib = {

    hyprland = {
      enable = true;
      user = userConfig.userName;
    };

    bluetooth.enable = true;

    appproxy = {
      enable = true;
      fqdn = "tower.home.arpa";
      tls = {
        certFile = config.sops.secrets."traefik/tls/cert".path;
        certKeyFile = config.sops.secrets."traefik/tls/certKey".path;
      };
      auth = {
        enable = true;
        jwtSecretFile = config.sops.secrets."authelia/jwtSecret".path;
        storageEncryptionKeyFile = config.sops.secrets."authelia/storageEncryptionKey".path;
        adminPassword = config.sops.placeholder."authelia/adminPassword";
      };
      apps.ai.urlPath = "/";
    };

    aistack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    python3

    # gpu monitoring
    rocmPackages.rocm-smi
    clinfo
    glances
  ];


  services.fwupd.enable = true;

  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
    "open-webui"
  ];

}
