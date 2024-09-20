{ pkgs, userConfig, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop/system
  ];

  profiles.base = {

    system = {
      hostName = "testbox";
      mainUser.name = userConfig.userName;
      stateVersion = "23.11";
      isVmGuest = true;
    };

    inherit (userConfig) localization;
  };

  profiles.desktop.enable = true;

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "mount_repo" ''
      mkdir /home/leo/nix-config
      sudo mount -t 9p -o trans=virtio,r repo /home/leo/nix-config
    '')
  ];

}

