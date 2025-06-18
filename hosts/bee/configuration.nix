{ pkgs, userConfig, ... }:
let
  hostName = "bee";
  ip = "192.168.1.50";
in
{

  system.stateVersion = "24.11";
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.enableAllTerminfo = true;

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
  };

  systemd.network.networks."10-lan" = {
    enable = true;
    matchConfig.Name = "enp1s0";
    address = [
      "${ip}/24"
    ];
    routes = [
      { Gateway = "192.168.1.1"; }
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
    firewallUDPPorts = [
      53
      853 # DoQUIC
    ];
    firewallTCPPorts = [
      53
      # 443 # DoH
      853 # DoT
      # 5380 # web interface HTTP
      53443 # web interface HTTPS
    ];
  };

  services.tailscale = {
    enable = false;
    openFirewall = true;
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

    bluetooth.enable = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    dig
    lsof
  ];

  programs.fish.enable = true;

}
