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
      inherit (cfg.system.mainUser) name;
      shell = pkgs.fish;
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