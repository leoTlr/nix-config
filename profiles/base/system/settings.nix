{ config, pkgs, ... }:
let 
  cfg = config.profiles.base;
in
{

  system.stateVersion = cfg.system.stateVersion;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    inherit (cfg.system) hostName;
    networkmanager.enable = true;
  };

  # https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
  sops = {
    defaultSopsFile = ../../../secrets.yaml;
    defaultSopsFormat = "yaml";
    gnupg.home = "/home/${cfg.system.mainUser.name}/.gnupg";
    secrets."${cfg.system.mainUser.name}/passwordHash".neededForUsers = true;
  };

  syslib = {
    users = {
      mutable = false;
      mainUser = {
        inherit (cfg.system.mainUser) name;
        shell = pkgs.fish;
        passwordHashPath = config.sops.secrets."${cfg.system.mainUser.name}/passwordHash".path;
      };
    };

    localization.enable = true;
    customFonts.enable = true;

    nh = {
      enable = true;
      flakePath = /home/${cfg.system.mainUser.name}/localrepo;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  programs.fish.enable = true;

  services.qemuGuest.enable = cfg.system.isVmGuest;

}