{ config, pkgs, commonSettings, ... }:

{
  
  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop/system
  ];

  profiles.base = {

    system = {
      hostName = "testbox";
      mainUserName = commonSettings.user.name;
      stateVersion = "23.11";
      isVmGuest = true;
    };

    inherit (commonSettings) localization;
  };

  profiles.desktop.enable = true;

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "mount_repo" ''
      mkdir /home/leo/localrepo
      sudo mount -t 9p -o trans=virtio,r repo /home/leo/localrepo
    '')
  ];

}

