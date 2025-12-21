{ pkgs, userConfig, ... }:
{
  profiles.base = {
    enable = true;
    stateVersion = "23.11";
    hostName = "lt-t14";
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [ "192.168.1.50" ];
  };

  syslib = {

    deploy.role = "deployer";
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
    nitrokey.enable = false;
  };

  environment.systemPackages = with pkgs; [
    python3
  ];

  services.fwupd.enable = true;

  services.tailscale = {
    enable = false;
    openFirewall = true;
    useRoutingFeatures = "both";
  };

}
