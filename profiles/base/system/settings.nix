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

  syslib = {
    users.mainUser = {
      name = cfg.system.mainUserName;
      shell = pkgs.fish;
    };

    localization.enable = true;
    customFonts.enable = true;

    nh = {
      enable = true;
      flakePath = /home/${cfg.system.mainUserName}/localrepo;
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  programs.fish.enable = true;

  services.qemuGuest.enable = cfg.system.isVmGuest;

}