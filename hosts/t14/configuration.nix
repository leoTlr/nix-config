{ userConfig, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../profiles/desktop/system
  ];

  profiles.base = {

    system = {
      hostName = "lt-t14";
      mainUser.name = userConfig.userName;
      stateVersion = "23.11";
    };

    inherit (userConfig) localization;
  };

  profiles.desktop.enable = true;

}

