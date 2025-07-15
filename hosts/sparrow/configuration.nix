{ pkgs, userConfig, ... }:
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

  sops.secrets."sabnzbd/apikey".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/nzbkey".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/A/host".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/A/port".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/A/connections".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/A/priority".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/A/username".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/A/password".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/B/host".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/B/port".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/B/connections".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/B/priority".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/B/username".sopsFile = ./secrets.yaml;
  sops.secrets."sabnzbd/servers/B/password".sopsFile = ./secrets.yaml;
  sops.gnupg.home= "/root/.gnupg";
  sops.gnupg.sshKeyPaths = [];
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
      #mediaDir =
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
