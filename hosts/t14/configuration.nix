{ config, pkgs, commonSettings, ... }:

{
  
  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop/system
  ];

  profiles.base = {

    system = {
      hostName = "lt-t14";
      mainUser.name = commonSettings.user.name;
      stateVersion = "23.11";
    };

    inherit (commonSettings) localization;
  };

  profiles.desktop.enable = true;

}

