{ config, pkgs, ... }:
let
  cfg = config.profiles.base;
in
{

  system.stateVersion = cfg.system.stateVersion;
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
    inherit (cfg.system) hostName;
    networkmanager.enable = true;
  };

  syslib = {

    users = {
      mutable = if cfg.system.mainUser.passwordHashPath == null then true else false;
      mainUser = {
        inherit (cfg.system.mainUser) name;
        shell = pkgs.fish;
      };
    };

    localization.enable = true;
    customFonts.enable = true;

    nh = {
      enable = true;
      flakePath = "/home/${cfg.system.mainUser.name}/nix-config";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    python3
  ];

  programs.fish.enable = true;

  services.qemuGuest.enable = cfg.system.isVmGuest;

}