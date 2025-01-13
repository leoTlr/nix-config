{ pkgs, userConfig, ... }:
let
  hostName = "bpi";
in
{

  system.stateVersion = "24.11";
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 30d";
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    inherit hostName;
    firewall.enable = true;
    useNetworkd = true;
  };

  systemd.network.networks."10-lan" = {
    enable = true;
    matchConfig.Name = "lan";
    networkConfig.DHCP = "ipv4";
  };

  syslib = {

    users = {
      mutable = true;
      mainUser = {
        name = userConfig.userName;
        shell = pkgs.fish;
      };
    };

    ssh = {
      enable = true;
      authorizedKeys.${userConfig.userName} = [ "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host" ];
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
  ];

  programs.fish.enable = true;

}
