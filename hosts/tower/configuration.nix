{ pkgs, config, userConfig, cfglib, lib, ... }:
{

  profiles = {
    base.stateVersion = "25.11";
    server.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    useNetworkd = false;
    nameservers = [ "192.168.1.50" ];
  };

  sops.secrets = {
    "alloy/user" = {};
    "alloy/apikey" = {};
    "traefik/certs/tower_cert" = { owner = "traefik"; restartUnits = ["traefik.service"]; };
    "traefik/certs/tower_key" = { owner = "traefik"; restartUnits = ["traefik.service"]; };
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

    customFonts.enable = true;
    bluetooth.enable = true;

    appproxy = {
      enable = true;
      fqdn = "tower.home.arpa";
      certs = [{
        certFile = config.sops.secrets."traefik/certs/tower_cert".path;
        keyFile = config.sops.secrets."traefik/certs/tower_key".path;
      }];
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
