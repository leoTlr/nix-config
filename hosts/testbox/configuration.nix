{ pkgs, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop/system
  ];

  profiles.base = {

    system = {
      hostName = "testbox";
      stateVersion = "23.11";
      isVmGuest = true;
    };

  };

  profiles.desktop.enable = true;

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "mount_repo" ''
      mkdir /home/leo/nix-config
      sudo mount -t 9p -o trans=virtio,r repo /home/leo/nix-config
    '')
  ];

}

