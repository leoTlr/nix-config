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
