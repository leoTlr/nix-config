{ pkgs, userConfig, ... }:
let
  hostName = "lt-t14";
in
{

  system.stateVersion = "23.11";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    inherit hostName;
    networkmanager.enable = true;
  };

  syslib = {

    nix.enable = true;

    users = {
      mutable = true;
      mainUser = {
        name = userConfig.userName;
        shell = pkgs.fish;
      };
    };

    localization = {
      enable = true;
      inherit (userConfig.localization) timezone locale keymap;
    };
    customFonts.enable = true;

    nh = {
      enable = true;
      flakePath = "/home/leo/nix-config";
    };

    hyprland = {
      enable = true;
      isVmGuest = false;
      user = userConfig.userName;
    };
    bluetooth.enable = false;
    displaylink.enable = false;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    python3
  ];

  programs.fish.enable = true;

  services.fwupd.enable = true;

}
