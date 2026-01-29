{ pkgs, config, userConfig, ... }:
{

  profiles.base = {
    enable = true;
    stateVersion = "26.05";
  };

  hardware.tuxedo-drivers.enable = true;
  boot = {
    kernelModules = [ "yt6801" ]; # ethernet
    extraModulePackages = with config.boot.kernelPackages; [ yt6801 ];
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [ "192.168.1.50" ];
  };

  syslib = {

    sshd = {
      enable = true;
      authorizedKeys.${userConfig.userName} = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTJPFx24iMt77z4a6unaq7EBMy8Hj+28vCZAJCbwdMi"];
    };

    deploy.role = "deployer";
    customFonts.enable = true;
    localization.keymap = "us";

    nh = {
      enable = true;
      flakePath = "/home/leo/nix-config";
    };

    hyprland = {
      enable = true;
      isVmGuest = false;
      user = userConfig.userName;
    };
  };

  environment.systemPackages = with pkgs; [
    python3
  ];

  services.fwupd.enable = true;

}
