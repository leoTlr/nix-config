{ config, commonSettings, ... }:

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

}

